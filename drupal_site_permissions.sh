#!/bin/bash
# drupal_site_permissions.sh - set permissions for htdocs and files

drupal_site_permissions=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "drupal_site_permissions setting ownership and permissions"

[ -z "$LOCAL_FILES_PATH" ] && error_exit "drupal_site_permissions requires LOCAL_FILES_PATH"
[ -z "$LOCAL_PATH" ] && error_exit "drupal_site_permissions requires REMOTE_PATH"
[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "drupal_site_permissions requires LOCAL_IS_PRODUCTION_SERVER"
[ -z "$LOCAL_USER" ] && error_exit "drupal_site_permissions requires LOCAL_USER"
[ -z "$LOCAL_USER_GROUP" ] && error_exit "drupal_site_permissions requires LOCAL_USER_GROUP"
[ -z "$LOCAL_USER_PHP" ] && error_exit "drupal_site_permissions requires LOCAL_USER_PHP"

FINAL_USER=$LOCAL_USER
FINAL_GROUP=$LOCAL_USER_GROUP
FINAL_USER_PHP=$LOCAL_USER_PHP

message "User: $FINAL_USER" "Group: $FINAL_GROUP" "PHP user: $FINAL_USER_PHP"

sudo chmod -R ug+w "$LOCAL_PATH" || error_exit "ug+w failed"
sudo chown -R $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH" || error_exit "set user:group to $FINAL_USER:$FINAL_GROUP failed"
sudo chown -Rh $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH/sites" || error_exit "set user:group of /sites failed"
sudo chmod -R g+s "$LOCAL_PATH/sites" || error_exit "g+s of /sites failed"

# for each subsite
FILES="$LOCAL_PATH/sites/*/files"
for subsite in $FILES
do
  echo "$subsite"
  sudo chown -Rh $FINAL_USER_PHP:$FINAL_GROUP "$subsite" || error_exit "set permissions for /files in $subsite failed"
done

message "drupal_site_permissions complete"
