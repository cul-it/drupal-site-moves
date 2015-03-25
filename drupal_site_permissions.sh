#!/bin/bash
# drupal_site_permissions.sh - set permissions for htdocs and files
# see https://www.drupal.org/node/244924

drupal_site_permissions=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "drupal_site_permissions setting ownership and permissions"

[ -z "$LOCAL_PRIVATE_FILES_PATH" ] && error_exit "drupal_site_permissions requires LOCAL_PRIVATE_FILES_PATH"
[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "drupal_site_permissions requires LOCAL_IS_PRODUCTION_SERVER"
[ -z "$LOCAL_PATH" ] && error_exit "drupal_site_permissions requires REMOTE_PATH"
[ -z "$LOCAL_USER" ] && error_exit "drupal_site_permissions requires LOCAL_USER"
[ -z "$LOCAL_USER_GROUP" ] && error_exit "drupal_site_permissions requires LOCAL_USER_GROUP"
[ -z "$LOCAL_USER_PHP" ] && error_exit "drupal_site_permissions requires LOCAL_USER_PHP"

FINAL_USER=$LOCAL_USER
FINAL_GROUP=$LOCAL_USER_GROUP
FINAL_USER_PHP=$LOCAL_USER_PHP

message "User: $FINAL_USER" "Group: $FINAL_GROUP" "PHP user: $FINAL_USER_PHP" "Site: $LOCAL_PATH" "Files: $LOCAL_PRIVATE_FILES_PATH"

echo ""
echo "Site: $LOCAL_PATH"

cd "$LOCAL_PATH" || error_exit "cd $LOCAL_PATH failed"
sudo chown -R $FINAL_USER:$FINAL_GROUP .
sudo find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;
sudo find . -type f -exec chmod u=rw,g=r,o= '{}' \;

# php has to write in sites/*/files
cd "$LOCAL_PATH/sites" || error_exit "cd $LOCAL_PATH/sites failed"
sudo chown -R $FINAL_USER_PHP:$FINAL_GROUP .
sudo find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
for d in ./*/files
do
   sudo find $d -type d -exec chmod ug=rwx,o= '{}' \;
   sudo find $d -type f -exec chmod ug=rw,o= '{}' \;
done

# php has to write in drupal_files
cd "$LOCAL_PATH/sites" || error_exit "cd $LOCAL_PATH/sites failed"
sudo chown -R $FINAL_USER_PHP:$FINAL_GROUP .
sudo find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
for d in ./*/files
do
   sudo find $d -type d -exec chmod ug=rwx,o= '{}' \;
   sudo find $d -type f -exec chmod ug=rw,o= '{}' \;
done

sudo chmod -R ug+w "$LOCAL_PATH" || error_exit "ug+w $LOCAL_PATH failed"
sudo chown -R $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH" || error_exit "set user:group to $FINAL_USER:$FINAL_GROUP failed"
sudo chown -Rh $FINAL_USER:$FINAL_GROUP "$LOCAL_PATH/sites" || error_exit "set user:group of /sites failed"
sudo chmod -R g+s "$LOCAL_PATH/sites" || error_exit "g+s of /sites failed"

# for each subsite
FILES="$LOCAL_PATH/sites/*/files"
for subsite in $FILES
do
  echo "Subsite: $subsite"
  sudo chown -Rh $FINAL_USER_PHP:$FINAL_GROUP "$subsite" || error_exit "set permissions for /files in $subsite failed"
done

# files directory
echo "Files: $LOCAL_PRIVATE_FILES_PATH"
sudo chown -Rh $FINAL_USER_PHP:$FINAL_GROUP "$LOCAL_PRIVATE_FILES_PATH" || error_exit "set owner for $LOCAL_PRIVATE_FILES_PATH failed"
sudo chmod 644 "$LOCAL_PRIVATE_FILES_PATH" || error_exit "set permissions for $LOCAL_PRIVATE_FILES_PATH failed"

message "drupal_site_permissions complete"
