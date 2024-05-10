#!/bin/sh

# Sets the scripts path and starts the relevant collector script(s).
# Can be directly called from the UI scheduler.

## Absolute path to this script: /opt/tomato-mqtt/collectorStart.sh
SCRIPT=$(readlink -f $0)
## Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname $SCRIPT)

## export it for the other scripts
## with trailing / because that way it also works directly from folder
export SCRIPTPATH="${SCRIPTPATH}/"

sh "${SCRIPTPATH}collector0.sh" &
#sh "${SCRIPTPATH}collector20.sh" &
sh "${SCRIPTPATH}collector30.sh" &
#sh "${SCRIPTPATH}collector40.sh" &
