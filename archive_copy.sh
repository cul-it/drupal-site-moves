#!/bin/bash
# restore_copy.sh - copy drush archive-dump archive to current machine

SCRIPT="site_archive"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1
function usage() {
  message "usage:" "$0 <path to archive>" "  archive is on another machine" "  user@machine:/path/to/archive.tar.gz" "  makes a local copy "
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

TEMP_DIR="/tmp/$USER/$SCRIPT"
sudo mkdir -p "$TEMP_DIR" || error_exit "Can not create $TEMP_DIR"
sudo chown -R "$USER" "/tmp/$USER" || error_exit "Can not set permissions /tmp/$USER."

SOURCE_PATH="$1"
SOURCE_FILENAME=$(basename $SOURCE_PATH)
TEMP_FILE="$TEMP_DIR/$SOURCE_FILENAME"

[ -f "$TEMP_FILE" ] && error_exit "$TEMP_FILE already exists"

message "Copy" "$SOURCE_PATH" "to"  "$TEMP_FILE"
ConfirmOrExit

message "copying $SOURCE_FILENAME" "to" "$TEMP_DIR"
scp "$SOURCE_PATH" "$TEMP_PATH" || error_exit "Could not copy $SOURCE_PATH"
