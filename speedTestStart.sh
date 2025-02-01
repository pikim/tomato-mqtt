#!/bin/sh

# Sets the scripts path and starts the speed test script.
# Can be directly called from the UI scheduler.

## Absolute path to this script: /opt/tomato-mqtt/speedTestStart.sh
SCRIPT=$(readlink -f "$0")
## Absolute path this script is in: /opt/tomato-mqtt
SCRIPTPATH=$(dirname "$SCRIPT")
## Change into that directory
cd "$SCRIPTPATH" || return

sh './speedTest.sh'

## Change into initial directory
cd - || return
