#!/bin/sh

# Sets the scripts path and starts the relevant collector script(s).
# Can be directly called from the UI scheduler.

## Absolute path to this script: /opt/tomato-mqtt/collectorStart.sh
SCRIPT=$(readlink -f "$0")
## Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname "$SCRIPT")
## Change into that directory
cd "$SCRIPTPATH" || return

sh "./collector0.sh" &
#sh "./collector20.sh" &
sh "./collector30.sh" &
#sh "./collector40.sh" &

## Change into initial directory
cd - || return
