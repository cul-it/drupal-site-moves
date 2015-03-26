#!/bin/bash
# set_permissions.sh - set up the ownership and permissions for a drupal site

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

LOCAL_SITE_NAME=$1
LOCAL_PATH=/libweb/sites/${LOCAL_SITE_NAME}/htdocs
LOCAL_PRIVATE_FILES_PATH=/libweb/sites/${LOCAL_SITE_NAME}/drupal_files
LOCAL_BACKUP_PATH=${LOCAL_PRIVATE_FILES_PATH}/movers/$SCRIPT_ID
LOCAL_USER=$USER
LOCAL_USER_GROUP=lib_web_dev_role
LOCAL_USER_PHP=apache

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

function usage() {
  message "usage:" "$0 <site name>" "  <site name> on one of the victorias (where you must be)" "" "  $1"
  exit 1
}

[ $# -eq 1 ] || usage "$0 needs 1 argument "

# $HOSTNAME on the servers
VICTORIA01=victoria01.serverfarm.cornell.edu
VICTORIA02=victoria02.serverfarm.cornell.edu
VICTORIA03=victoria03.library.cornell.edu

# Make sure we're on the test machine
if [ "$HOSTNAME" != "$LOCAL_MACHINE" ]; then
  usage "Expecting to run $0 for $REMOTE_SITE_NAME on $LOCAL_MACHINE"
fi

# use 0 for test server 1 for production server
case "$HOSTNAME" in
  "$VICTORIA01" | "$VICTORIA03") LOCAL_IS_PRODUCTION_SERVER=1 ;;
  "$VICTORIA02") LOCAL_IS_PRODUCTION_SERVER=0 ;;
  *) error_exit "Unexpected hostname $HOSTNAME" ;;
esac

# be sure sites exist where they should
[ -d "$LOCAL_PATH" ] || error_exit "can't find $LOCAL_PATH on $LOCAL_MACHINE"

sudo echo "Thanks."
message "Hello $LOCAL_USER." "This will set all the file ownership and permissions on" $LOCAL_SITE_NAME
ConfirmOrExit

source ${SCRIPTPATH}/drupal_site_permissions.sh

message "set_permissions complete" "have a nice day."
