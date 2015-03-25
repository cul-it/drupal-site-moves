#!/bin/bash
# test_drupal_site_permissions.sh

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

REMOTE_MACHINE=victoria01.library.cornell.edu
REMOTE_SITE_NAME=$1
REMOTE_PATH=/libweb/sites/${REMOTE_SITE_NAME}/htdocs
REMOTE_FILES_PATH=/libweb/sites/${REMOTE_SITE_NAME}/drupal_files
REMOTE_BACKUP_PATH=${REMOTE_FILES_PATH}/movers/$SCRIPT_ID
REMOTE_USER=$USER

LOCAL_MACHINE=victoria02.serverfarm.cornell.edu
LOCAL_SITE_NAME=LAW
LOCAL_PATH=/Applications/MAMP/htdocs/law
LOCAL_FILES_PATH=/Applications/MAMP/htdocs/law_files
LOCAL_BACKUP_PATH=${LOCAL_FILES_PATH}/movers/$SCRIPT_ID
LOCAL_USER=$USER
LOCAL_USER_GROUP=wheel
LOCAL_USER_PHP=Guest

#always include at least default
SUBSITES=(default )

#*********************************************
#*********************************************
#*** customize above here
#*********************************************
#*********************************************

LOCAL_IS_PRODUCTION_SERVER=1

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

source ${SCRIPTPATH}/drupal_site_permissions.sh
