#!/bin/bash
# set_permissions_victoria.sh - set up the ownership and permissions for a drupal site

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"
SCRIPT="migration"

LOCAL_USER=$USER
LOCAL_SITE_NAME=$1
LOCAL_PATH=/libweb/sites/${LOCAL_SITE_NAME}/htdocs
LOCAL_PRIVATE_FILES_PATH=/libweb/sites/${LOCAL_SITE_NAME}/drupal_files
LOCAL_SITE_MOVES_AREA=/tmp/${LOCAL_USER}/${SCRIPT}/${LOCAL_SITE_NAME}
LOCAL_SITE_MOVES_DIRECTORY=${LOCAL_SITE_MOVES_AREA}
LOCAL_USER_GROUP=lib_web_dev_role
LOCAL_USER_PHP=apache

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

function usage() {
  message "usage:" "$0 <site name>" "  <site name> on one of the victorias (where you must be)" "" "  $1"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

# $HOSTNAME on the servers
VICTORIA01=victoria01.serverfarm.cornell.edu
VICTORIA02=victoria02.serverfarm.cornell.edu
VICTORIA03=victoria03.library.cornell.edu

# use 0 for test server 1 for production server
case "$HOSTNAME" in
  "$VICTORIA01" | "$VICTORIA03") LOCAL_IS_PRODUCTION_SERVER=1 ;;
  "$VICTORIA02") LOCAL_IS_PRODUCTION_SERVER=0 ;;
  *) error_exit "Unexpected hostname $HOSTNAME" ;;
esac

# be sure sites exist where they should
[ -d "$LOCAL_PATH" ] || error_exit "can't find $LOCAL_PATH on $LOCAL_MACHINE"

message "Hello $LOCAL_USER." "This will set all the file ownership and permissions on" $LOCAL_SITE_NAME

# set up the local work area for pull_site_from_production or pull_site_from_test
sudo mkdir -p "$LOCAL_SITE_MOVES_DIRECTORY" || error_exit "Can't make directory $LOCAL_SITE_MOVES_DIRECTORY"
sudo chmod -R ug=rwX,o=rX "$LOCAL_SITE_MOVES_DIRECTORY" || error_exit "Can't chmod directory $LOCAL_SITE_MOVES_DIRECTORY"
sudo chgrp -R "$LOCAL_USER_GROUP" "$LOCAL_SITE_MOVES_DIRECTORY" || error_exit "Can't chgrp directory $LOCAL_SITE_MOVES_DIRECTORY"

source ${SCRIPTPATH}/drupal_site_permissions.sh

message "set_permissions complete" "have a nice day."
