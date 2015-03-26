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

message "User: $FINAL_USER" "Group: $FINAL_GROUP" "PHP user: $FINAL_USER_PHP"

sudo echo "Site: $LOCAL_PATH"

cd "$LOCAL_PATH" || error_exit "cd $LOCAL_PATH failed"
sudo chown -R $FINAL_USER:$FINAL_GROUP .
sudo find . -type d -exec chmod u=rwx,g=rx,o=rx '{}' \;
sudo find . -type f -exec chmod u=rw,g=r,o=r '{}' \;

# php has to write in sites/*/files (subsite/files)
cd "$LOCAL_PATH/sites" || error_exit "cd $LOCAL_PATH/sites failed"
sudo chown -R $FINAL_USER_PHP:$FINAL_GROUP .
sudo find . -type d -name files -exec chmod ug=rwx,o=rx '{}' \;
for d in $LOCAL_PATH/sites/*/files
do
  echo "Subsite: ${d}"
  [ -d "${d}" ] || error_exit "$d is not a directory"
  sudo find $d -type d -exec chmod ug=rwx,o= '{}' \;
  sudo find $d -type f -exec chmod ug=rw,o= '{}' \;
done

# sites/all/<modules,themes,libraries> writable by group if this is a test server (.git and .svn)
if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 0 ]; then
  echo "Allow for .git and .svn on test servers"
  sudo chmod -R g+w "$LOCAL_PATH/sites/all"
fi

echo "Private Files: $LOCAL_PRIVATE_FILES_PATH"
# php has to write in private files directory
cd "$LOCAL_PRIVATE_FILES_PATH" || error_exit "cd $LOCAL_PRIVATE_FILES_PATH failed"
sudo chown -R $FINAL_USER_PHP:$FINAL_GROUP .
sudo find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
sudo find . -type f -exec chmod u=rw,g=r,o= '{}' \;

# settings.php should not be writable
for d in $LOCAL_PATH/sites/*/settings.php
do
  echo "Settings: ${d}"
  [ -f "${d}" ] || error_exit "$d is not a file"
  sudo chmod ug=r,o= "${d}"
  sudo chown $FINAL_USER_PHP:$FINAL_GROUP "${d}"
done

message "drupal_site_permissions complete"
