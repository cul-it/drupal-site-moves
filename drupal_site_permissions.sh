#!/bin/bash
# drupal_site_permissions.sh - set permissions for htdocs and files

drupal_site_permissions=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "drupal_site_permissions setting ownership and permissions"

[ -z "$LOCAL_FILES_PATH" ] && error_exit "local_drupal_db_restore requires LOCAL_FILES_PATH"
[ -z "$LOCAL_PATH" ] && error_exit "local_drupal_db_restore requires REMOTE_PATH"
[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "local_drupal_db_restore requires LOCAL_IS_PRODUCTION_SERVER"

FINAL_USER=$LOCAL_USER
FINAL_GROUP=$LOCAL_USER_GROUP
FINAL_USER_PHP=$LOCAL_USER_PHP

sudo chmod -R ug+w "$LOCAL_PATH"
sudo chown -R $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH"
sudo chown -Rh $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH/sites"
sudo chmod -R g+s "$LOCAL_PATH/sites"

# for each subsite
FILES="$LOCAL_PATH/sites/*"
for subsite in $FILES
do
  echo "$subsite/files"
  sudo chown -Rh $FINAL_USER_PHP:$FINAL_GROUP "$subsite/files"
done

message "drupal_site_permissions complete"
