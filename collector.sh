#!/bin/sh
sh /jffs/tomato-grafana/checkDisk.sh &
sh /jffs/tomato-grafana/checkBandwidthInterface.sh &
sh /jffs/tomato-grafana/checkConnections.sh &
sh /jffs/tomato-grafana/pingGoogle.sh &
sh /jffs/tomato-grafana/checkLoad.sh &
sh /jffs/tomato-grafana/checkCPUTemp.sh &
sh /jffs/tomato-grafana/checkMem.sh &
sh /jffs/tomato-grafana/checkCPU.sh &
sh /jffs/tomato-grafana/checkClients.sh &
