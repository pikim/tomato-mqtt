#!/bin/sh

# Runs collector script after 30 seconds.

sleep 30
#sh "${SCRIPTPATH}collector.sh"

# only the scripts below need to run twice a minute
sh "${SCRIPTPATH}checkAccessRestriction.sh" &
sh "${SCRIPTPATH}checkAdBlock.sh" &
