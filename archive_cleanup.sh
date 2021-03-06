#!/bin/bash
# archive_cleanup.sh - remove archived sites

SCRIPT="site_archive"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

TEMP_DIR="/tmp/$USER/$SCRIPT"
message "Archived sites" "Remove one or more of these files?"
ls -l "$TEMP_DIR"
ConfirmOrExit
rm -r -i "$TEMP_DIR"
