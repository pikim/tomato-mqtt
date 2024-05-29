#!/bin/sh

# Runs collector script after 30 seconds.

sleep 30
#sh "./collector.sh"

. "./common.sh"
# only the scripts below need to run twice a minute
. "./checkAccessRestriction.sh" &
. "./checkAdBlock.sh" &
wait