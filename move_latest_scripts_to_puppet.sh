#!/bin/bash
# move_latest_scripts_to_puppet.sh - update puppet's site moving scripts

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"


STAMP=`date +'%Y%m%d_%H%M%S'`

WORK_DIR="$HOME/${SCRIPT_ID}_${STAMP}"
SVN_SCRIPTS=https://svn.library.cornell.edu/cul-drupal/scripts
SVN_SCRIPTS_DIR="$WORK_DIR/scripts"
GIT_MOVER_SCRIPTS=git@github.com:cul-it/drupal-site-moves.git
GIT_MOVER_SCRIPTS_DIR="$WORK_DIR/drupal-site-moves"
PUPPET_SCRIPTS=https://svn.library.cornell.edu/puppet/modules/webserver/files/drupal
PUPPET_SCRIPTS_DIR="$WORK_DIR/drupal"

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

function usage() {
  message "usage:" "$0 --fire-bazooka" "  checks out latest scripts from drupal-site-moves" "  checks out latest from cul-drupal/scripts"  "  checks out puppet/modules/webserver/files/drupal"  "  copies selected scripts to puppet" "  checks in puppet scripts" "  $1"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

[ "$1" = "--fire-bazooka" ] || usage

message "working in $WORK_DIR"

mkdir -p "$WORK_DIR" || error_exit "mkdir $WORK_DIR failed"
cd "$WORK_DIR" || error_exit "cd to $WORK_DIR failed"
echo "Building $SVN_SCRIPTS_DIR"
svn co --quiet "$SVN_SCRIPTS" && [ -d "$SVN_SCRIPTS_DIR" ] || error_exit "can't get $SVN_SCRIPTS"
echo "Building $GIT_MOVER_SCRIPTS_DIR"
git clone -q "$GIT_MOVER_SCRIPTS" && [ -d "$GIT_MOVER_SCRIPTS_DIR" ] || error_exit "can't get $GIT_MOVER_SCRIPTS"
echo "Building $PUPPET_SCRIPTS_DIR"
svn co --quiet "$PUPPET_SCRIPTS" && [ -d "$PUPPET_SCRIPTS_DIR" ] || error_exit "can't get $PUPPET_SCRIPTS"

svns=(dr-make.sh dr-move-db.sh dr-move-files.sh move-goldsen-to-production.sh move-goldsen-to-test.sh update_test_from_victoria03.sh update_victoria03_from_test.sh)
svns_remove=(set_drupal_permissions.sh )

for file in "${svns[@]}"
do
  foo="$SVN_SCRIPTS_DIR/$file"
  target="$PUPPET_SCRIPTS_DIR/$file"
  echo $foo
  [ -f "$target" ] || NEWFILES+=("$file")
  [ -f $foo ] && mv "$foo" "$PUPPET_SCRIPTS_DIR/" || error_exit "can't move $foo"
done

gits=(customize_robots_txt.sh drupal_site_permissions.sh find_who_runs_php.php flow_functions.sh local_drupal_db_restore.sh pull_site_from_production.sh pull_site_from_test.sh remote_drupal_db_backup.sh remote_drupal_pull_files.sh set_permissions.sh)
for file in "${gits[@]}"
do
  foo="$GIT_MOVER_SCRIPTS_DIR/$file"
  target="$PUPPET_SCRIPTS_DIR/$file"
  echo $foo
  [ -f "$target" ] || NEWFILES+=("$file")
  [ -f $foo ] && mv "$foo" "$PUPPET_SCRIPTS_DIR/" || error_exit "can't move $foo"
done

message "committing the changes to svn for puppet"

for file in "${svns_remove[@]}"
do
  foo="$PUPPET_SCRIPTS_DIR/$file"
  if [ -f $foo ] ;then
    cd "$PUPPET_SCRIPTS_DIR" || error_exit "cd to $PUPPET_SCRIPTS_DIR failed"
    svn delete "$file" || error_exit "can't remove $foo"
  fi
done

for file in "${NEWFILES[@]}"
do
  echo "adding $file"
  cd "$PUPPET_SCRIPTS_DIR" || error_exit "cd to $PUPPET_SCRIPTS_DIR failed"
  svn add "$file" || error_exit "can't svn add $file"
done
svn commit -m 'Latest versions of drupal site move and maker scripts from "$SCRIPT_ID"' || error_exit "commit failed"

message "Done. Check $WORK_DIR"
