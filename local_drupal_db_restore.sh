#!/bin/bash
# local_drupal_db_restore.sh - restore after a remote_drupal_db_backup

local_drupal_db_restore=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1
[ -z "remote_drupal_db_backup" ] && echo "$0 requires remote_drupal_db_backup.sh" && exit 1

message "local_drupal_db_restore preflight"

[ -z "$LOCAL_PATH" ] && error_exit "local_drupal_db_restore requires REMOTE_PATH"
[ -z "$LOCAL_MACHINE" ] && error_exit "local_drupal_db_restore requires REMOTE_MACHINE"
[ -z "$LOCAL_USER" ] && error_exit "local_drupal_db_restore requires REMOTE_USER"
[ -z "$LOCAL_SITE_MOVES_BACKUP_PATH" ] && error_exit "local_drupal_db_restore requires REMOTE_SITE_MOVES_BACKUP_PATH"
[ -z "$STAMP" ] && error_exit "local_drupal_db_restore requires STAMP (time stamp)"
[ -z "$LOCAL_SITE_NAME" ] && error_exit "local_drupal_db_restore requires REMOTE_SITE_NAME"
[ -z "$SUBSITE" ] && SUBSITE=default

LOCAL_SUBSITE_PATH="${LOCAL_PATH}/sites/$SUBSITE"
LOCAL_BACKUP_FILE="${LOCAL_SITE_MOVES_BACKUP_PATH}/dd_${SUBSITE}.sql.gz"

[ -d "$LOCAL_SUBSITE_PATH" ] || error_exit "no directory for $LOCAL_SUBSITE_PATH"
[ -f "$LOCAL_BACKUP_FILE" ] || error_exit "no local backup file $LOCAL_BACKUP_FILE"

cd $LOCAL_SUBSITE_PATH || error_exit "can't get to $LOCAL_SUBSITE_PATH"
echo "...CHECK"

# see if site is up and running (drush sql-connect always works!)
SITE_IS_UP=1
"$LOCAL_DRUSH" vget site_name || SITE_IS_UP=0
if [ $SITE_IS_UP -eq 1 ] ;then
  message "putting $LOCAL_SITE_NAME into maintenance mode"
  "$LOCAL_DRUSH" vset --yes maintenance_mode 1
  "$LOCAL_DRUSH" cc all
else
  echo "site is not running. Will attempt to load database..."
fi
echo "...CHECK"

message "restoring database from backup" $LOCAL_BACKUP_FILE
gunzip < $LOCAL_BACKUP_FILE | drush sqlc || error_exit "can't restore backup"
echo "...CHECK"

if [ $SITE_IS_UP -eq 1 ] ;then
  message "taking $LOCAL_SITE_NAME out of maintenance mode"
  "$LOCAL_DRUSH" vset --yes maintenance_mode 0
  "$LOCAL_DRUSH" cc all
  echo "...CHECK"
fi

message "local_drupal_db_restore complete"
