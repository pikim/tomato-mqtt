#!/bin/sh

sh "${SCRIPTPATH}checkCPU.sh"
sh "${SCRIPTPATH}checkMem.sh" &
sh "${SCRIPTPATH}checkDisk.sh" &
sh "${SCRIPTPATH}checkLoad.sh" &
sh "${SCRIPTPATH}checkPing.sh" &
sh "${SCRIPTPATH}checkClients.sh" &
sh "${SCRIPTPATH}checkWireless.sh" &
sh "${SCRIPTPATH}checkConnections.sh" &
sh "${SCRIPTPATH}checkBandwidthInterface.sh" &
sh "${SCRIPTPATH}checkAccessRestriction.sh" &
sh "${SCRIPTPATH}checkAdBlock.sh" &
