#!/bin/bash
# archive_www.library.cornell.edu.sh - create drush archive-dump of www.library.cornell.edu

SITENAME=www.library.cornell.edu
SITEPATH=/libweb/sites/$SITENAME/htdocs

SCRIPT="$0"
BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

# SITEPATH must be valid drupal site
cd "$SITEPATH" || error_exit "invalid site path $SITEPATH"
which drush || error_exit "No drush!!!"
drush status root || error_exit "not a valid drupal site $SITEPATH"

TEMP_DIR="/tmp/$USER/$SCRIPT"
sudo mkdir -p "$TEMP_DIR" || error_exit "Can not create $TEMP_DIR"
sudo chown -R "$USER" "/tmp/$USER" || error_exit "Can not set permissions /tmp/$USER."

STAMP=`date +'%Y%m%d_%H%M%S'`
TEMP_PATH="$TEMP_DIR/$SITENAME-$STAMP"
TEMP_FILE="$TEMP_PATH/archive.tar.gz"

sudo mkdir -p "$TEMP_PATH" || error_exit "Could not create $TEMP_PATH"
sudo chown "$USER" "$TEMP_PATH" || error_exit "Could not make $TEMP_PATH writable"

message "Creating archive..."

drush archive-dump --destination="$TEMP_FILE" --tar-options="--exclude=.git --gzip" || "Could not create archive $TEMP_FILE"

message "Archive:" "$TEMP_FILE" "$USER@$HOSTNAME:$TEMP_FILE"
