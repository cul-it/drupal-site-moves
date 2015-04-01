#!/bin/bash
# pull_site_from_test.sh - move a drupal site from test to current production machine

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

REMOTE_USER=$USER
REMOTE_MACHINE=victoria02.library.cornell.edu
REMOTE_SITE_NAME=$1
REMOTE_PATH=/libweb/sites/${REMOTE_SITE_NAME}/htdocs
REMOTE_PRIVATE_FILES_PATH=/libweb/sites/${REMOTE_SITE_NAME}/drupal_files
REMOTE_SITE_MOVES_DIRECTORY=/tmp/drupal-site-moves/${REMOTE_USER}
REMOTE_BACKUP_PATH=${REMOTE_SITE_MOVES_DIRECTORY}/$SCRIPT_ID

LOCAL_USER=$USER
LOCAL_MACHINE=victoria01.serverfarm.cornell.edu
LOCAL_SITE_NAME=$2
LOCAL_PATH=/libweb/sites/${LOCAL_SITE_NAME}/htdocs
LOCAL_PRIVATE_FILES_PATH=/libweb/sites/${LOCAL_SITE_NAME}/drupal_files
LOCAL_SITE_MOVES_DIRECTORY=/tmp/drupal-site-moves/${LOCAL_USER}
LOCAL_BACKUP_PATH=${LOCAL_SITE_MOVES_DIRECTORY}/$SCRIPT_ID
LOCAL_USER_GROUP=lib_web_dev_role
LOCAL_USER_PHP=apache

#always include at least default
SUBSITES=(default )

#*********************************************
#*********************************************
#*** customize above here
#*********************************************
#*********************************************

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

function usage() {
  message "usage:" "$0 <test domain> <production domain>" "  <test domain> on victoria02" "  <production domain> can be on victoria01 or victoria03 (where you must be)"  "" "  $1"
  exit 1
}

[ $# -eq 2 ] || usage "$0 needs 2 arguments"

# $HOSTNAME on the servers
VICTORIA01=victoria01.serverfarm.cornell.edu
VICTORIA02=victoria02.serverfarm.cornell.edu
VICTORIA03=victoria03.library.cornell.edu

# check site arguments
case "$LOCAL_SITE_NAME" in
  "www.library.cornell.edu" | "beta.library.cornell.edu")
    LOCAL_MACHINE=$VICTORIA03
    ;;
  *)
    LOCAL_MACHINE=$VICTORIA01
esac

# Make sure we're on the production machine
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
ssh "$REMOTE_USER@$REMOTE_MACHINE" "test -d $REMOTE_PATH || exit 86"
[ $? -eq 0 ] || error_exit "can't find $REMOTE_PATH on $REMOTE_MACHINE"

sudo echo "Thanks."
message "Hello $LOCAL_USER." "This will move the files and database from" $REMOTE_SITE_NAME "to" $LOCAL_SITE_NAME
ConfirmOrExit

if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 1 ] ;then
  message "You are running on a production server: $LOCAL_MACHINE" "Are you sure you want to replace $LOCAL_SITE_NAME?"
  ConfirmOrExit
else
  message "Your are running on a test server: $LOCAL_MACHINE" "Please let the production site users know you're working with the site."
  ConfirmOrExit
fi


STAMP=`date +'%Y%m%d_%H%M%S'`

source ${SCRIPTPATH}/remote_drupal_db_backup.sh

source ${SCRIPTPATH}/remote_drupal_pull_files.sh

source ${SCRIPTPATH}/local_drupal_db_restore.sh

source ${SCRIPTPATH}/customize_robots_txt.sh

source ${SCRIPTPATH}/drupal_site_permissions.sh

message "pull_site_from_production complete" "have a nice day."
