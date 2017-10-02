#!/bin/bash
# find_drush.sh - export a path to drush
case "$HOSTNAME" in
  "lib-dev-037.serverfarm.cornell.edu")
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    ;;
esac

which drush || exit 1
