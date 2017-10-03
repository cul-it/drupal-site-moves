#!/bin/bash
# archive_wwwtest.sh - create drush archive-dump of wwwtest.library.cornell.edu

SITENAME=wwwtest.library.cornell.edu
SITEPATH=/cul/web/$SITENAME/htdocs

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

# SITEPATH must be valid drupal site
cd "$SITEPATH" || error_exit "invalid site path $SITEPATH"
drush status root || error_exit "not a valid drupal site"


STAMP=`date +'%Y%m%d_%H%M%S'`
TEMP_PATH="/tmp/$USER/archive_wwwtest/$SITENAME-$STAMP/"
TEMP_FILE="$TEMP_PATH/archive.tar.gz"

sudo mkdir -p "$TEMP_PATH" || error_exit "Could not create $TEMP_PATH"

message "Creating archive..."

drush archive-dump --destination="$TEMP_FILE" --tar-options="--exclude=.git --gzip" || "Could not create archive $TEMP_FILE"

message "Archive:" "$TEMP_FILE" "$USER@$HOSTNAME:$TEMP_FILE"
