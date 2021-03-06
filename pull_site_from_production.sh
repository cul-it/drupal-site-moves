#!/bin/bash
# pull_site_from_production.sh - move a drupal site from production to current

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

REMOTE_USER=$USER
REMOTE_MACHINE=victoria01.library.cornell.edu
REMOTE_SITE_NAME=$1
REMOTE_PATH=/libweb/sites/${REMOTE_SITE_NAME}/htdocs
REMOTE_PRIVATE_FILES_PATH=/libweb/sites/${REMOTE_SITE_NAME}/drupal_files
REMOTE_SCRIPT_TMP_DIRECTORY=/tmp/drupal-site-moves
REMOTE_SITE_MOVES_AREA=${REMOTE_SCRIPT_TMP_DIRECTORY}/${USER}/${REMOTE_SITE_NAME}
REMOTE_SITE_MOVES_DIRECTORY=${REMOTE_SITE_MOVES_AREA}
REMOTE_SITE_MOVES_BACKUP_PATH=${REMOTE_SITE_MOVES_DIRECTORY}/${SCRIPT_ID}
REMOTE_USER_GROUP=lib_web_dev_role
REMOTE_DRUSH=/usr/bin/drush

LOCAL_USER=$USER
LOCAL_MACHINE=lib-dev-037.serverfarm.cornell.edu
LOCAL_SITE_NAME=$2
LOCAL_PATH=/cul/web/${LOCAL_SITE_NAME}/htdocs
LOCAL_PRIVATE_FILES_PATH=/cul/web/${LOCAL_SITE_NAME}/drupal_files
LOCAL_SCRIPT_TMP_DIRECTORY=/tmp/drupal-site-moves
LOCAL_SITE_MOVES_USER_DIRECTORY=${LOCAL_SCRIPT_TMP_DIRECTORY}/${USER}
LOCAL_SITE_MOVES_AREA=${LOCAL_SITE_MOVES_USER_DIRECTORY}/${LOCAL_SITE_NAME}
LOCAL_SITE_MOVES_DIRECTORY=${LOCAL_SITE_MOVES_AREA}
LOCAL_SITE_MOVES_BACKUP_PATH=${LOCAL_SITE_MOVES_DIRECTORY}/${SCRIPT_ID}
LOCAL_USER_GROUP=diglibdev-role
LOCAL_USER_PHP=apache
LOCAL_DRUSH=/users/jgr25/.composer/vendor/bin/drush

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
  message "usage:" "$0 <production domain> <test domain>" "  <production domain> can be on victoria01 or victoria03" "  <test domain> on victoria02 (where you must be)" "" "  $1"
  exit 1
}

[ $# -eq 2 ] || usage "$0 needs 2 arguments "

# $HOSTNAME on the servers
VICTORIA01=victoria01.serverfarm.cornell.edu
VICTORIA02=lib-dev-037.serverfarm.cornell.edu
VICTORIA03=victoria03.library.cornell.edu

# check site arguments
case "$REMOTE_SITE_NAME" in
  "goldsen.library.cornell.edu")
    usage "goldsen site has a special move script"
    ;;
  "www.library.cornell.edu" | "beta.library.cornell.edu")
    REMOTE_MACHINE=$VICTORIA03
    ;;
  *)
    REMOTE_MACHINE=$VICTORIA01
esac

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
ssh "$REMOTE_USER@$REMOTE_MACHINE" "test -d $REMOTE_PATH || exit 86"
[ $? -eq 0 ] || error_exit "can't find $REMOTE_PATH on $REMOTE_MACHINE"

sudo echo "Thanks."
message "Hello $LOCAL_USER." "This will move the files and database from" $REMOTE_SITE_NAME "to" $LOCAL_SITE_NAME
ConfirmOrExit

if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 1 ] ;then
  message "You are running on a production server: $LOCAL_MACHINE"
  ConfirmOrExit
else
  message "Your are running on a test server: $LOCAL_MACHINE" "Please let the production site users know you're working with the site."
  ConfirmOrExit
fi

# set up the local tmp file directory for all users of this script
sudo mkdir -p "$LOCAL_SCRIPT_TMP_DIRECTORY"
sudo chgrp -R "$LOCAL_USER_GROUP" "$LOCAL_SCRIPT_TMP_DIRECTORY"
sudo chmod -R ug=rwX,o=rX "$LOCAL_SCRIPT_TMP_DIRECTORY"

# set up the work area for this script
sudo mkdir -p "$LOCAL_SITE_MOVES_AREA"
sudo chmod -R ug=rwX,o=rX "$LOCAL_SITE_MOVES_AREA"
sudo chown -R "${LOCAL_USER}:${LOCAL_USER_GROUP}" "$LOCAL_SITE_MOVES_USER_DIRECTORY"
#sudo chgrp -R "$LOCAL_USER_GROUP" "$LOCAL_SITE_MOVES_AREA"

STAMP=`date +'%Y%m%d_%H%M%S'`

source ${SCRIPTPATH}/remote_drupal_db_backup.sh

source ${SCRIPTPATH}/remote_drupal_pull_files.sh

source ${SCRIPTPATH}/local_drupal_db_restore.sh

source ${SCRIPTPATH}/customize_robots_txt.sh

source ${SCRIPTPATH}/drupal_site_permissions.sh

message "pull_site_from_production complete" "have a nice day."
