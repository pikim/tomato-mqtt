#!/bin/sh

# Determine the order of the scripts and whether they are executed synchronously at the
# same time (line ending with `&`) or asynchronously one after the other.

# It's not recommended to also run checkCPU.sh synchronously as this will distort its
# results. If this is intended anyhow, it's highly recommended to source variables.sh
# first by uncommenting the following line.

. "./common.sh"

. "./checkCPU.sh"
. "./checkMem.sh" &
. "./checkDisk.sh" &
. "./checkLoad.sh" &
. "./checkPing.sh" &
. "./checkLeases.sh" &
. "./checkClients.sh" &
. "./checkWireless.sh" &
. "./checkConnections.sh" &
. "./checkBandwidthInterface.sh" &
. "./checkAccessRestriction.sh" &
. "./checkAdBlock.sh" &

wait
