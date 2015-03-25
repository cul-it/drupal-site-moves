#!/bin/bash
# flow-functions.sh - error, exit, message, etc.
# include it like this:
#
# BASEDIR=$(dirname $0)
# source ${BASEDIR}/flow-functions.sh

flow_functions=1

function error_exit
{
  echo "*******************      *******************"
  echo "*******************      *******************"
  echo "*******************      *******************"
  echo "$1" 1>&2
  echo "*******************"
  echo "*******************"
  exit 1
}

function message
{
  echo ""
  echo "*************************************"
  echo "**"
  for var in "$@"
  do
    echo "** $var"
  done
  echo "**"
  echo "*************************************"
  echo ""
}

function ConfirmOrExit() {
while true
do
echo -n "Please confirm (y or n) :"
read CONFIRM
case $CONFIRM in
y|Y|YES|yes|Yes) break ;;
n|N|no|NO|No)
echo Aborting - you entered $CONFIRM
exit
;;
*) echo Please enter only y or n
esac
done
echo You entered $CONFIRM. Continuing ...
}
