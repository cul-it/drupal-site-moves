#!/bin/bash
# find_drush.sh - export a path to drush
case "$HOSTNAME" in
  "lib-dev-037.serverfarm.cornell.edu")
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    ;;
esac

echo "Looking for drush"
which drush || exit 1
