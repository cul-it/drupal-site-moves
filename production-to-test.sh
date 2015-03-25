#!/bin/bash
# production-to-test.sh

STAMP=`date +'%Y%m%d_%H%M%S'`

function usage() {
  message "usage: $0 <what to move>" "Choices for what to move:" "files - move just the file system" "databases - move just the databases" "both - move both"
  error_exit "Please try again."
}

# Make sure we're on the test machine
if [ "$HOSTNAME" != "$LOCAL_MACHINE" ]; then
  error_exit "Only run $0 on $LOCAL_MACHINE"
fi

[ $# -eq 1 ] || usage

MOVE_FILES=1
MOVE_DATABASES=1
case "$1" in
  files ) MOVE_DATABASES=0;;
  databases ) MOVE_FILES=0;;
  both ) ;;
  *) usage
esac

message "This will move the $SITE_NAME site" "from $REMOTE_PATH ($REMOTE_MACHINE)" "to $LOCAL_PATH ($LOCAL_MACHINE)"
ConfirmOrExit

if [ $MOVE_FILES -eq 1 ]; then
  # rsync entire site to local
  #  --dry-run to test
  message "moving site files"
  # --exclude=sites/*/settings.php
  sudo rsync -avcz --delete --omit-dir-times --chmod=ug=rwX --exclude=sites/*/settings.php \
    $REMOTE_USER@$REMOTE_MACHINE:$REMOTE_PATH/ $LOCAL_PATH/ || error_exit "can't move site files"
fi

if [ $MOVE_DATABASES -eq 1 ]; then

  mysql --version || error_exit "can't use mysql"
  drush --version || error_exit "can't use drush"
  which drush
  php --version || error_exit "can't use php"

  # set up remote backup directory
  CMD=""
  CMD="$CMD mkdir -p ${REMOTE_BACKUP_PATH} ;"
  CMD="$CMD echo ${STAMP} > ${REMOTE_BACKUP_PATH}/timestamp.txt"
  SCRIPT="eval \$($CMD)"
  ssh "${REMOTE_USER}@${REMOTE_MACHINE}" "${SCRIPT}" || error_exit "can't make directory {REMOTE_BACKUP_PATH} on remote machine"

  for site in "${SUBSITES[@]}"
  do
    message "Moving database for $site"
    SUBSITE=`echo $site | sed 's/\./_/g'`
    REMOTE_SUBSITE_PATH="${REMOTE_PATH}/sites/$site"
    LOCAL_SUBSITE_PATH="${LOCAL_PATH}/sites/$site"

    # make sure local site is there
    cd $LOCAL_SUBSITE_PATH || error_exit "can't get to $LOCAL_SUBSITE_PATH"

    # the remote file gets .gz added by drush
    REMOTE_BACKUP_FILE="${REMOTE_BACKUP_PATH}/dd_${SUBSITE}.sql"
    LOCAL_BACKUP_FILE="${LOCAL_BACKUP_PATH}/dd_${SUBSITE}.sql.gz"

    # backup default database to private directory
    message "backing up REMOTE Drupal database" "to $REMOTE_BACKUP_FILE.gz"
    CMD="drush vset maintenance_mode 1 ; drush cc all ; rm "${REMOTE_BACKUP_FILE}.gz" ; drush sql-dump --gzip --result-file=$REMOTE_BACKUP_FILE || error_exit \"Can't make database backup\" ; drush vset maintenance_mode 0 ; drush cc all ; "
    SCRIPT="cd \"$REMOTE_SUBSITE_PATH\" ; eval \$($CMD)"
    #echo $SCRIPT
    ssh -l "${REMOTE_USER}" "${REMOTE_MACHINE}" "${SCRIPT}"
    REMOTE_BACKUP_FILE=${REMOTE_BACKUP_FILE}.gz
  done

  message "moving backups from" $REMOTE_BACKUP_PATH "to" $LOCAL_BACKUP_PATH
  mkdir -p $LOCAL_BACKUP_PATH || error_exit "can't make $LOCAL_BACKUP_PATH"
  sudo rsync -avc --delete --omit-dir-times --chmod=ug=rwX \
    ${REMOTE_USER}@${REMOTE_MACHINE}:$REMOTE_BACKUP_PATH/ $LOCAL_BACKUP_PATH/ || error_exit "can't move backups"

  for site in "${SUBSITES[@]}"
  do
    message "Moving database for $site"
    SUBSITE=`echo $site | sed 's/\./_/g'`
    REMOTE_SUBSITE_PATH="${REMOTE_PATH}/sites/$site"
    LOCAL_SUBSITE_PATH="${LOCAL_PATH}/sites/$site"

    # load the database dump on the target machine
    message "installing $site database backup in target Drupal subsite" $LOCAL_SUBSITE_PATH
    cd $LOCAL_SUBSITE_PATH
    # see if site is up and running (drush sql-connect always works!)
    SITE_IS_UP=1
    drush vget site_name || SITE_IS_UP=0
    if [ $SITE_IS_UP -eq 1 ] ;then
      drush vset maintenance_mode 1 || error_exit "can't put $site in maintenance mode"
      drush cc all || error_exit "can't clear cache in $site"
    fi
    gunzip < $LOCAL_BACKUP_FILE | drush sqlc || error_exit "can't restore backup"
    if [ $SITE_IS_UP -eq 1 ] ;then
      drush vset maintenance_mode 0 || error_exit "can't take $site out of maintenance mode"
      drush cc all || error_exit "can't clear cache in $site 2"
    fi
  done
fi

message "have a nice day"
