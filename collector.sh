#!/bin/sh
sh "${SCRIPTPATH}/checkCPU.sh"
sh "${SCRIPTPATH}/checkMem.sh" &
sh "${SCRIPTPATH}/checkLoad.sh" &
sh "${SCRIPTPATH}/checkDisk.sh" &
sh "${SCRIPTPATH}/checkWireless.sh" &
sh "${SCRIPTPATH}/checkAccessRestriction.sh" &
sh "${SCRIPTPATH}/checkBandwidthInterface.sh" &
sh "${SCRIPTPATH}/checkConnections.sh" &
sh "${SCRIPTPATH}/checkClients.sh" &
sh "${SCRIPTPATH}/pingGoogle.sh" &
