#!/bin/sh

# Absolute path to this script: /opt/tomato-mqtt/collectorSingle.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname $SCRIPT)

# export it for the other scripts
# with trailing / because that way it also works directly from folder
export SCRIPTPATH="${SCRIPTPATH}/"

sh "${SCRIPTPATH}speedTest.sh"
