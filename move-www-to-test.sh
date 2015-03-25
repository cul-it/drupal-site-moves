#!/bin/bash
# move-www-to-test.sh - honkingduck site

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

SITE_NAME=www.library.cornell.edu
REMOTE_PATH=/libweb/sites/${SITE_NAME}/htdocs
REMOTE_MACHINE=victoria03.library.cornell.edu
REMOTE_USER=$USER
REMOTE_BACKUP_PATH=/libweb/sites/${SITE_NAME}/drupal_files/movers/$SCRIPT_ID
LOCAL_SITE_NAME=main1.test.library.cornell.edu
LOCAL_PATH=/libweb/sites/${LOCAL_SITE_NAME}/htdocs
LOCAL_BACKUP_PATH=/libweb/sites/${LOCAL_SITE_NAME}/drupal_files/movers/$SCRIPT_ID
LOCAL_MACHINE=victoria02.serverfarm.cornell.edu

#always include at least default
SUBSITES=(default )

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow-functions.sh
source ${BASEDIR}/production-to-test.sh
