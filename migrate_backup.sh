#!/bin/bash
# migrate_backup.sh - prepare Drupal site backup on current machine

SCRIPT="migration"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

function usage() {
  message "usage:" "$0 <site name>" "  site can be on victorias or jgr25-dev"  "  $1"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

case "$HOSTNAME" in
  victoria01.library.cornell.edu | victoria02.library.cornell.edu | victoria03.library.cornell.edu )
    SITESPATH=/libweb/sites
    ;;
  lib-dev-037.serverfarm.cornell.edu | jgr25-dev.library.cornell.edu )
    SITESPATH=/cul/web
    ;;
  *)
    usage "$0 has to run on machine where the site is, not $HOSTNAME"
esac

message "On this machine" $HOSTNAME "the sites are here:" $SITESPATH

SITENAME=$1
SITE="$SITESPATH/$SITENAME"
SITEROOT="$SITE/htdocs"
SITEFILES="$SITE/drupal_files"

[ -d "$SITEROOT" ] || error_exit "Missing required root directory: $SITEROOT"
[ -d "$SITEFILES" ] || error_exit "Missing required files directory: $SITEFILES"

# SITEROOT must be valid drupal site
cd "$SITEROOT" || error_exit "invalid site path $SITEROOT"
which drush || error_exit "No drush!!!"
drush status root || error_exit "not a valid drupal site $SITEROOT"

TEMP_DIR="/tmp/$USER/$SCRIPT"
sudo mkdir -p "$TEMP_DIR" || error_exit "Can not create $TEMP_DIR"
sudo chown -R "$USER" "/tmp/$USER" || error_exit "Can not set permissions /tmp/$USER"

STAMP=`date +'%Y%m%d_%H%M%S'`
TARGET="$TEMP_DIR/$SITENAME"
mkdir -p "$TARGET" || error_exit "Can't make target directory: $TARGET"
TARGETSQL="$TARGET/db.sql"
echo $STAMP > "$TARGET/created.txt"

message "Copying" "$SITEROOT" "to" "$TARGET"
rsync -avcz --delete \
  --omit-dir-times --no-perms --no-times --no-group --chmod=ug=rwX \
  --exclude=sites/*/settings.php \
  --exclude=.svn --exclude=.git \
  "$SITEROOT" "$TARGET/" || error_exit "rsync failed to copy $SITEROOT"

message "Copying" "$SITEFILES" "to" "$TARGET"
rsync -avcz --delete \
  --omit-dir-times --no-perms --no-times --no-group --chmod=ug=rwX \
  --exclude=.svn --exclude=.git \
  "$SITEFILES" "$TARGET/" || error_exit "rsync failed to copy $SITEFILES"

message "Dumping database to" "$TARGETSQL"
cd "$SITEROOT"
drush --root="$SITEROOT" vset --always-set maintenance_mode 1 || error_exit "could not enter maintenance mode"
drush --root="$SITEROOT" cc all || echo "Could not clear cache"
drush --root="$SITEROOT" sql-dump --ordered-dump  --result-file="$TARGETSQL" || error_exit "Could not sql-dump"
drush --root="$SITEROOT" vset --always-set maintenance_mode 0 || error_exit "could not exit maintenance mode"

message "Setting Permissions in" "$TARGET"
sudo chown -R "$USER:$USER" "$TARGET"
sudo chmod -R u+r "$TARGET"

message "Backup Complete" "$TARGET" "Go to target machine and type" "rsync -avcz $USER@$HOSTNAME:$TARGET/ $TARGET/"
