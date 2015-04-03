#!/bin/bash
# remote_directory_path.sh - build a directory path on a remote machine
# mkdir -p does not set permissions on directories in the middle of the path
#   when run on remote machine

remote_directory_path=1

BASEDIR=$(dirname $0)
source ${BASEDIR}/flow_functions.sh

[ -z "$flow_functions" ] && echo "$0 requires flow_functions.sh" && exit 1

function usage() {
  message "usage:" "/bin/bash ${BASEDIR}/$0 <machine> <user> <group> <path>" "  <machine> remote machine name" "  <user> user name on remote machine" "  <group> group name on remote machine" "  <path> absolute directory path - with leading slash" "  do not source, execute with /bin/bash" "" "  $1"
  exit 1
}

[ $# -eq 4 ] || usage "$0 needs 4 arguments "

REMOTE_MACHINE="$1"
REMOTE_USER="$2"
REMOTE_GROUP="$3"

function rcmd () {
  SCRIPT="$1"
  /usr/bin/ssh "${REMOTE_USER}@${REMOTE_MACHINE}" "${SCRIPT}"
  if [ "$?" -ne 0 ]; then
    return 1;
  else
    return 0;
  fi
}

# remove leading slash from path so it won't genereate an array element
PARTS=`echo "$4" | cut -c 2-`

rcmd "mkdir -p $4"

# make array of directories in path
IFS="/" read -ra DIRECTORIES <<< "$PARTS"

PATH=""
for d in "${DIRECTORIES[@]}"; do
  PATH="$PATH/$d"
  rcmd "test -d \"${PATH}\""
  found=$?
  if [ "$found" -ne 0 ]; then
    echo "path $PATH does not exist"
    rcmd "mkdir \"${PATH}\""
    made=$?
    if [ "$made" -ne 0 ]; then
      error_exit "can not make remote directory $PATH"
    fi
  fi
  rcmd "chgrp ${REMOTE_GROUP} ${PATH}"
  group=$?
  rcmd "chmod g+w ${PATH}"
  mod=$?
done

rcmd "cd $4 ; cd ../ ; pwd ; ls -l"