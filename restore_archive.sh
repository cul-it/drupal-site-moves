#!/bin/bash
# restore_archive.sh - restore drush archive-dump archive to current drupal site

SCRIPT="site_archive"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1
function usage() {
  message "usage:" "$0 <path to archive>" "  archive must be on this machine"  "  current directory must be a Drupal site"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

SITEPATH=`pwd`
which drush || error_exit "No drush!!!"
drush -q vget clean_url || error_exit "not a valid drupal site $SITEPATH"

SOURCE_PATH="$1"
SOURCE_FILENAME=$(basename $SOURCE_PATH)

message "This will overwrite the files and database in" "$SITEPATH" "and replace them with" "$SOURCE_PATH"
ConfirmOrExit

drush archive-restore --overwrite "$SOURCE_PATH"

message "Restored from archive" "$SOURCE_PATH"
