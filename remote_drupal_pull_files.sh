#!/bin/bash
# remote_drupal_pull_files.sh - get the remote site's files to the local site

remote_drupal_pull_files=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "remote_drupal_pull_files preflight"

[ -z "$LOCAL_SITE_MOVES_BACKUP_PATH" ] && error_exit "remote_drupal_pull_files requires LOCAL_SITE_MOVES_BACKUP_PATH"
[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "remote_drupal_pull_files requires LOCAL_IS_PRODUCTION_SERVER"
[ -z "$LOCAL_MACHINE" ] && error_exit "remote_drupal_pull_files requires LOCAL_MACHINE"
[ -z "$LOCAL_PATH" ] && error_exit "remote_drupal_pull_files requires LOCAL_PATH"
[ -z "$LOCAL_PRIVATE_FILES_PATH" ] && error_exit "remote_drupal_pull_files requires LOCAL_PRIVATE_FILES_PATH"
[ -z "$LOCAL_SITE_NAME" ] && error_exit "remote_drupal_pull_files requires LOCAL_SITE_NAME"
[ -z "$LOCAL_USER" ] && error_exit "remote_drupal_pull_files requires LOCAL_USER"
[ -z "$REMOTE_SITE_MOVES_BACKUP_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_SITE_MOVES_BACKUP_PATH"
[ -z "$REMOTE_MACHINE" ] && error_exit "remote_drupal_pull_files requires REMOTE_MACHINE"
[ -z "$REMOTE_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_PATH"
[ -z "$REMOTE_PRIVATE_FILES_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_PRIVATE_FILES_PATH"
[ -z "$REMOTE_SITE_NAME" ] && error_exit "remote_drupal_pull_files requires REMOTE_SITE_NAME"
[ -z "$REMOTE_USER" ] && error_exit "remote_drupal_pull_files requires REMOTE_USER"

[ -d "$LOCAL_PATH" ] || error_exit "no directory for $LOCAL_PATH"
[ -d "$LOCAL_PRIVATE_FILES_PATH" ] || error_exit "no directory for $LOCAL_PRIVATE_FILES_PATH"

# set up local backup directory
mkdir -p -v \"${LOCAL_SITE_MOVES_BACKUP_PATH}\"
[ -d \"${LOCAL_SITE_MOVES_BACKUP_PATH}\" ] || error_exit 'make directory $LOCAL_SITE_MOVES_BACKUP_PATH failed'

echo "...CHECK"

message "putting $LOCAL_SITE_NAME into maintenance mode"
/bin/bash ${BASEDIR}/drupal_maintenance_mode.sh enter $LOCAL_PATH

[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "remote_drupal_pull_files requires LOCAL_IS_PRODUCTION_SERVER"
[ -z "$LOCAL_MACHINE" ] && error_exit "remote_drupal_pull_files requires LOCAL_MACHINE"
[ -z "$LOCAL_PATH" ] && error_exit "remote_drupal_pull_files requires LOCAL_PATH"
[ -z "$LOCAL_PRIVATE_FILES_PATH" ] && error_exit "remote_drupal_pull_files requires LOCAL_PRIVATE_FILES_PATH"
[ -z "$LOCAL_SITE_NAME" ] && error_exit "remote_drupal_pull_files requires LOCAL_SITE_NAME"
[ -z "$LOCAL_USER" ] && error_exit "remote_drupal_pull_files requires LOCAL_USER"
[ -z "$REMOTE_SITE_MOVES_BACKUP_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_SITE_MOVES_BACKUP_PATH"
[ -z "$REMOTE_MACHINE" ] && error_exit "remote_drupal_pull_files requires REMOTE_MACHINE"
[ -z "$REMOTE_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_PATH"
[ -z "$REMOTE_PRIVATE_FILES_PATH" ] && error_exit "remote_drupal_pull_files requires REMOTE_PRIVATE_FILES_PATH"
[ -z "$REMOTE_SITE_NAME" ] && error_exit "remote_drupal_pull_files requires REMOTE_SITE_NAME"
[ -z "$REMOTE_USER" ] && error_exit "remote_drupal_pull_files requires REMOTE_USER"

[ -d "$LOCAL_PATH" ] || error_exit "no directory for $LOCAL_PATH"
[ -d "$LOCAL_PRIVATE_FILES_PATH" ] || error_exit "no directory for $LOCAL_PRIVATE_FILES_PATH"

#test
[ -d \"${LOCAL_SITE_MOVES_BACKUP_PATH}\" ] || error_exit '2 directory $LOCAL_SITE_MOVES_BACKUP_PATH does not exist'

# rsync entire site to local
#  --dry-run to test
#  --no-perms --no-times so we don't have to use sudo rsync
message "moving site code files (htdocs) from" $REMOTE_PATH "to" $LOCAL_PATH
# --exclude=sites/*/settings.php
if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 1 ] ;then
  # do not delete extra files in the target when moving to production
  rsync -avcz -e "ssh -l $REMOTE_USER" --omit-dir-times --no-perms --no-times --chmod=ug=rwX \
    --exclude=sites/*/settings.php \
    --exclude=sites/all/* \
    $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PATH/ $LOCAL_PATH/ || error_exit "can't move site files"

  # but DO delete extra files in modules/libraries/themes
  rsync -avcz -e "ssh -l $REMOTE_USER" --delete --omit-dir-times --no-perms --no-times --chmod=ug=rwX \
    --exclude=sites/*/settings.php \
    $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PATH/sites/all/ $LOCAL_PATH/sites/all/ || error_exit "can't move site files"
else
    rsync -avcz -e "ssh -l $REMOTE_USER" --delete --omit-dir-times --no-perms --no-times --chmod=ug=rwX  \
  --exclude=sites/*/settings.php \
  $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PATH/ $LOCAL_PATH/ || error_exit "can't move site files"
fi

message "moving site private files (drupal_files) from" $REMOTE_PRIVATE_FILES_PATH "to" $LOCAL_PRIVATE_FILES_PATH

#test
[ -d \"${LOCAL_SITE_MOVES_BACKUP_PATH}\" ] || error_exit '1 directory $LOCAL_SITE_MOVES_BACKUP_PATH does not exist'

if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 1 ] ;then
  # do not delete extra files in the target when moving to production
  rsync -avcz -e "ssh -l $REMOTE_USER" --omit-dir-times --no-perms --no-times --chmod=ug=rwX \
    $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PRIVATE_FILES_PATH/ $LOCAL_PRIVATE_FILES_PATH/ || error_exit "can't move production site private files"
else
  rsync -avcz -e "ssh -l $REMOTE_USER" --delete --omit-dir-times --no-perms --no-times --chmod=ug=rwX  \
  $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PRIVATE_FILES_PATH/ $LOCAL_PRIVATE_FILES_PATH/ || error_exit "can't move site private files"
fi
echo "...CHECK"

message "moving database backup from" $REMOTE_SITE_MOVES_BACKUP_PATH "to" $LOCAL_SITE_MOVES_BACKUP_PATH
[ -d \"${LOCAL_SITE_MOVES_BACKUP_PATH}\" ] || error_exit 'directory $LOCAL_SITE_MOVES_BACKUP_PATH does not exist'
rsync -avcz -e "ssh -l $REMOTE_USER" --delete --omit-dir-times --no-perms --no-times --chmod=ug=rwX  \
  $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_SITE_MOVES_BACKUP_PATH/ $LOCAL_SITE_MOVES_BACKUP_PATH/ || error_exit "can't move site backup files"

message "getting $LOCAL_SITE_NAME out of maintenance mode"
cd $LOCAL_PATH || error_exit "can not get to $LOCAL_PATH"
drush vset maintenance_mode 0
drush cc all
echo "...CHECK"

message "remote_drupal_pull_files complete"

