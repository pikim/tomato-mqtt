#!/bin/sh

# Sets the scripts path and starts the speed test script.
# Can be directly called from the UI scheduler.

## Absolute path to this script: /opt/tomato-mqtt/speedTestStart.sh
SCRIPT=$(readlink -f $0)
## Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname $SCRIPT)

## export it for the other scripts
## with trailing / because that way it also works directly from folder
export SCRIPTPATH="${SCRIPTPATH}/"

sh "${SCRIPTPATH}speedTest.sh"
