#!/bin/sh

# Absolute path to this script: /opt/tomato-mqtt/collectorSingle.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname $SCRIPT)

# export it for the other scripts
export SCRIPTPATH="$SCRIPTPATH"

sh "$SCRIPTPATH/collector0.sh" &
#sh "$SCRIPTPATH/collector20.sh" &
sh "$SCRIPTPATH/collector30.sh" &
#sh "$SCRIPTPATH/collector40.sh" &
