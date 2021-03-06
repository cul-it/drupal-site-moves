#!/bin/bash
# drupal_maintenance_mode.sh - enter/exit maintenance mode

drupal_maintenance_mode=1

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

function usage() {
  message "usage:" "/bin/bash ${BASEDIR}/$0 <enter or exit> <path to site directory> <path to drush>" "  <enter or exit>
  'enter' or 'exit'" "  <path to site directory> directory where the settings.php file for this site lives" "do not source, execute with /bin/bash " "" "  $1"
  exit 1
}

[ $# -eq 3 ] || usage "$0 needs 3 arguments "

case "$1" in
  'enter' ) SETTING=1
    ;;
  'exit' ) SETTING=0
    ;;
  *) usage "First argument must be enter or exit"
    ;;
esac

[ -d "$2" ] || usage "Second argument must be an existing directory"

[ -f "$3" ] || usage "Third argument must be a path to drush"
DRUSH_PATH="$3"

cd "$2" || error_exit "can not change directory to $2"
"$DRUSH_PATH" vset --yes maintenance_mode "$SETTING" || error_exit "drush vset maintenance_mode failed"
"$DRUSH_PATH" cc all || error_exit "drush cache clear failed"

exit 0
