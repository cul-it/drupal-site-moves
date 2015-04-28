#!/bin/bash
# remote_drupal_db_backup.sh

remote_drupal_db_backup=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "remote_drupal_db_backup preflight"

[ -z "$REMOTE_PATH" ] && error_exit "remote_drupal_db_backup requires REMOTE_PATH"
[ -z "$REMOTE_MACHINE" ] && error_exit "remote_drupal_db_backup requires REMOTE_MACHINE"
[ -z "$REMOTE_USER" ] && error_exit "remote_drupal_db_backup requires REMOTE_USER"
[ -z "$REMOTE_USER_GROUP" ] && error_exit "remote_drupal_db_backup requires REMOTE_USER_GROUP"
[ -z "$REMOTE_SITE_MOVES_BACKUP_PATH" ] && error_exit "remote_drupal_db_backup requires REMOTE_SITE_MOVES_BACKUP_PATH"
[ -z "$STAMP" ] && error_exit "remote_drupal_db_backup requires STAMP (time stamp)"
[ -z "$REMOTE_SITE_NAME" ] && error_exit "remote_drupal_db_backup requires REMOTE_SITE_NAME"
[ -z "$SUBSITE" ] && SUBSITE=default

REMOTE_SUBSITE_PATH="\"${REMOTE_PATH}\"/sites/$SUBSITE"
# the remote file gets .gz added by drush
REMOTE_BACKUP_FILE="${REMOTE_SITE_MOVES_BACKUP_PATH}/dd_${SUBSITE}.sql"
REMOTE_TIMESTAMP_FILE="${REMOTE_SITE_MOVES_BACKUP_PATH}/timestamp.txt"

function rcmd () {
  SCRIPT="cd \"$REMOTE_SUBSITE_PATH\" ; eval \$($1)"
  ssh "${REMOTE_USER}@${REMOTE_MACHINE}" "${SCRIPT}"
  if [ "$?" -ne 0 ]; then
    echo "Script step failed: $1";
    exit 1;
  fi
}

# set up remote backup directory
BASEDIR=$(dirname $0)
/bin/bash ${BASEDIR}/remote_directory_path.sh "$REMOTE_MACHINE" "$REMOTE_USER" "$REMOTE_USER_GROUP" "${REMOTE_SITE_MOVES_BACKUP_PATH}"
[ "$?" -eq 0 ] || error_exit "remote_directory_path.sh failed"
rcmd "echo ${STAMP} > ${REMOTE_TIMESTAMP_FILE} || echo 'write timestamp failed' && exit 1 "
echo "...CHECK"

message "backing up database" "  machine:  $REMOTE_MACHINE" "  site: $REMOTE_SITE_NAME" "  subsite: $SUBSITE" "  destination: $REMOTE_BACKUP_FILE.gz"

rcmd "[ -f \"${REMOTE_BACKUP_FILE}.gz\" ] && rm \"${REMOTE_BACKUP_FILE}.gz\""
rcmd "drush --root=$REMOTE_PATH vset --yes maintenance_mode 1 "
rcmd "drush --root=$REMOTE_PATH cc all "
rcmd "drush --root=$REMOTE_PATH sql-dump --gzip --result-file=\"$REMOTE_BACKUP_FILE\""
rcmd "drush --root=$REMOTE_PATH vset --yes maintenance_mode 0 "
rcmd "drush --root=$REMOTE_PATH cc all "

REMOTE_BACKUP_FILE=${REMOTE_BACKUP_FILE}.gz
echo "...CHECK"


message "Site $REMOTE_SITE_NAME database backed up to" $REMOTE_BACKUP_FILE
echo "...CHECK"

