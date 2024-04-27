#!/bin/sh
sh ./checkCPU.sh &
sh ./checkMem.sh &
sh ./checkLoad.sh &
sh ./checkDisk.sh &
sh ./checkWireless.sh &
sh ./checkAccessRestriction.sh &
sh ./checkBandwidthInterface.sh &
sh ./checkConnections.sh &
sh ./checkClients.sh &
sh ./pingGoogle.sh &
