#!/bin/bash
# customize_robots_txt.sh - keep webcrawlers off of test/stage server sites

customize_robots_txt=1

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

message "customize_robots_txt customizing"

[ -z "$LOCAL_PATH" ] && error_exit "local_drupal_db_restore requires REMOTE_PATH"
[ -z "$LOCAL_IS_PRODUCTION_SERVER" ] && error_exit "local_drupal_db_restore requires LOCAL_IS_PRODUCTION_SERVER"

if [ "$LOCAL_IS_PRODUCTION_SERVER" -eq 1 ] ;then
  # find the production version stashed away by dr-make.sh
  [ -f "$LOCAL_PATH/production_robots.txt" ] || error_exit "can't find robots.txt production version $LOCAL_PATH/production_robots.txt"
  sudo cp -f "$LOCAL_PATH/production_robots.txt" "$LOCAL_PATH/robots.txt"
else
  # test/stg servers get a restrictive one to keep web crawlers out
  sudo echo -e 'User-agent: *\nDisallow: /' > "$LOCAL_PATH/robots.txt"
fi

message "customize_robots_txt customization complete"
