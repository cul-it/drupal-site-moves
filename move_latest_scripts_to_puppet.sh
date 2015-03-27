#!/bin/bash
# move_latest_scripts_to_puppet.sh - update puppet's site moving scripts

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

SVN_SCRIPTS=https://svn.library.cornell.edu/cul-drupal/scripts
SVN_SCRIPT_DIR=scripts
GIT_MOVER_SCRIPTS=git@github.com:cul-it/drupal-site-moves.git
GIT_MOVER_SCRIPT_DIR="drupal-site-moves"
PUPPET_SCRIPTS=https://svn.library.cornell.edu/puppet/modules/webserver/files/drupal
PUPPET_SCRIPTS_DIR=drupal

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

function usage() {
  message "usage:" "$0 --fire-bazooka" "  checks out latest scripts from drupal-site-moves" "  checks out latest from cul-drupal/scripts"  "  checks out puppet/modules/webserver/files/drupal"  "  copies selected scripts to puppet" "  checks in puppet scripts" "  $1"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

[ "$1" = "--fire-bazooka" ] || usage

STAMP=`date +'%Y%m%d_%H%M%S'`

WORK_DIR="~/{SCRIPT_ID}_${STAMP}"

mkdir -p $WORK_DIR || error_exit "mkdir $WORK_DIR failed"
cd $WORK_DIR || error_exit "cd to $WORK_DIR failed"
svn co "$SVN_SCRIPTS" && [ -d "$SVN_SCRITPS_DIR" ] || error_exit "can't get $SVN_SCRIPTS"
git clone "$GIT_MOVER_SCRIPTS" && [ -d "GIT_MOVER_SCRIPTS_DIR" ] || error_exit "can't get $GIT_MOVER_SCRIPTS"
svn co "$PUPPET_SCRIPTS" && [ -d "$PUPPET_SCRIPTS_DIR" ] || error_exit "can't get $PUPPET_SCRIPTS"

svns=(dr-make.sh dr-move-db.sh dr-move-files.sh move-goldsen-to-production.sh move-goldsen-to-test.sh update_test_from_victoria03.sh update_victoria03_from_test.sh)
svns_remove=(set_drupal_permissions.sh update_production_from_test.sh update_test_from_production.sh)

for file in "${svns[@]}"
do
  foo="$SVN_SCRIPTS_DIR/$file"
  [ -f $foo ] && mv "$path" "$PUPPET_SCRIPTS_DIR/" || error_exit "can't move $foo"
done

for file in "${svns_remove[@]}"
do
  foo="$PUPPET_SCRIPTS_DIR/$file"
  if [ -f $foo ] ;then
    svn delete "$foo" "$PUPPET_SCRIPTS_DIR/" || error_exit "can't remove $foo"
  fi
done

gits=(customize_robots_txt.sh drupal_site_permissions.sh find_who_runs_php.php flow_functions.sh local_drupal_db_restore.sh pull_site_from_production.sh pull_site_from_test.sh remote_drupal_db_backup.sh remote_drupal_pull_files.sh set_permissions.sh)
for file in "${gits[@]}"
do
  foo="GIT_MOVER_SCRIPT_DIR/$file"
  [ -f $foo ] && mv "$path" "$PUPPET_SCRIPTS_DIR/" || error_exit "can't move $foo"
done

error_exit "check $WORK_DIR"
