#!/bin/bash
# extra_files_test.sh - deposit extra files throughout the site and check if they are there
#   tests that existing files are preserved as expected during site moves


pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

filename=$(basename $0)
SCRIPT_ID="${filename%.*}"

LOCAL_SITE_NAME=$1
LOCAL_PATH=/libweb/sites/${LOCAL_SITE_NAME}/htdocs
LOCAL_PRIVATE_FILES_PATH=/libweb/sites/${LOCAL_SITE_NAME}/drupal_files
LOCAL_SITE_MOVES_DIRECTORY=${LOCAL_PRIVATE_FILES_PATH}/movers
LOCAL_USER=$USER
LOCAL_USER_GROUP=lib_web_dev_role
LOCAL_USER_PHP=apache

CRAZY_FILE_NAME="${SCRIPT_ID}_whack_a_mole.txt"

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

function usage() {
  message "usage:" "$0 <site name> <action>" "  <site name> on one of the victorias (where you must be)"  "  <action> either set, check or clear"  "  creates/checks/deletes some dummy files in various site directories" "" "  $1"
  exit 1
}

[ $# -eq 2 ] || usage "$0 needs 2 arguments "

ACTION=$2

SITES_FILES="$LOCAL_PATH/sites/default/files"
MODULES="$LOCAL_PATH/site/all/modules"
THEMES="$LOCAL_PATH/site/all/themes"
LIBRARIES="$LOCAL_PATH/site/all/libraries"

tests=("$LOCAL_PATH" "$LOCAL_PRIVATE_FILES_PATH" "$LOCAL_SITE_MOVES_DIRECTORY" "$SITES_FILES" "$MODULES" "$THEMES" "$LIBRARIES")

echo "Host: $HOSTNAME"

for test in "${tests[@]}"
do
  foo="$test/$CRAZY_FILE_NAME"
  case "$ACTION" in
    set)
      [ -f "$foo" ] && echo "Found $foo" || touch "$foo" && echo "Wrote $foo" || error_exit "writing $foo failed"
      ;;
    check)
      [ -f "$foo" ] && echo "Found $foo" || echo "Did NOT find $foo"
      ;;
    clear)
      [ -f "$foo" ] && rm "$foo" && echo "Deleted $foo"
      ;;
    *) usage "<action> must be set, find, or clear"
  esac
done

message "have a nice day"
