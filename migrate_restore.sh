#!/bin/bash
# migrate-restore.sh - restore a local site from a migrate_backup.sh backup

SCRIPT="migration"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

function usage() {
  message "usage:" "$0 <source domain name> <target domain name>" \
  "  <source domain name> name of backup in /tmp/$USER/$SCRIPT" \
  "  <target domain name> site on this machine" \
  "  sites can be on victorias or jgr25-dev"  "  $1"
  echo "Backups:"
  cd "/tmp/$USER/$SCRIPT"
  pwd
  ls -lt
  exit 1
}

[ $# -eq 2 ] || usage "$0 needs 2 arguments "

case "$HOSTNAME" in
  victoria01.serverfarm.cornell.edu | victoria02.serverfarm.cornell.edu | victoria03.library.cornell.edu )
    SITESPATH=/libweb/sites
    ;;
  lib-dev-037.serverfarm.cornell.edu | jgr25-dev.library.cornell.edu )
    SITESPATH=/cul/web
    ;;
  *)
    usage "$0 has to run on machine where the site is, not $HOSTNAME"
esac

message "On this machine" $HOSTNAME "the sites are here:" $SITESPATH

BACKUPNAME=$1
BACKUP="/tmp/$USER/$SCRIPT/$BACKUPNAME"
BACKUPROOT="$BACKUP/htdocs"
BACKUPFILES="$BACKUP/drupal_files"
BACKUPSQL="$BACKUP/db.sql"

[ -d "$BACKUPROOT" ] || error_exit "Missing required backup root directory: $BACKUPROOT"
[ -d "$BACKUPFILES" ] || error_exit "Missing required backup files directory: $BACKUPFILES"
[ -f "$BACKUPSQL" ] || error_exit "Missing required backup database: $BACKUPSQL"

SITENAME=$2
SITE="$SITESPATH/$SITENAME"
SITEROOT="$SITE/htdocs"
SITEFILES="$SITE/drupal_files"

[ -d "$SITEROOT" ] || error_exit "Missing required root directory: $SITEROOT"
[ -d "$SITEFILES" ] || error_exit "Missing required files directory: $SITEFILES"

# SITEROOT must be valid drupal site
cd "$SITEROOT" || error_exit "invalid site path $SITEROOT"
which drush || error_exit "No drush!!!"
drush status root || error_exit "not a valid drupal site $SITEROOT"

message "About to replace site" "$SITEROOT" "with" "$BACKUP"
ConfirmOrExit

drush --root="$SITEROOT" vset --always-set maintenance_mode 1 || error_exit "could not enter maintenance mode"

message "Replacing htdocs" "$SITEROOT" "with" "$BACKUPROOT"
sudo rsync -avcz --delete \
  --omit-dir-times --no-perms --no-times --no-group --chmod=ug=rwX \
  --exclude=sites/*/settings.php \
  --exclude=.svn --exclude=.git \
  "$BACKUPROOT/" "$SITEROOT/" || error_exit "rsync failed to replace $SITEROOT"

message "Replacing files" "$SITEFILES" "with" "$BACKUPFILES"
sudo rsync -avcz --delete \
  --omit-dir-times --no-perms --no-times --no-group --chmod=ug=rwX \
  --exclude=.svn --exclude=.git \
  "$BACKUPFILES/" "$SITEFILES/" || error_exit "rsync failed to copy $SITEFILES"

message "Overwriting database with" "$BACKUPSQL"
drush --root="$SITEROOT" sql-cli < "$BACKUPSQL"

drush --root="$SITEROOT" vset --always-set maintenance_mode 0 || error_exit "could not exit maintenance mode"

message "Update complete." "$SITEROOT"

