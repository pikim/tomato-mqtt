#!/bin/sh
sleep 20
/jffs/tomato-grafana/checkBandwidthInterface.sh &
/jffs/tomato-grafana/checkConnections.sh &
/jffs/tomato-grafana/pingGoogle.sh &
/jffs/tomato-grafana/checkLoad.sh &
/jffs/tomato-grafana/checkCPUTemp.sh &
/jffs/tomato-grafana/checkMem.sh &
/jffs/tomato-grafana/checkCPU.sh &
/jffs/tomato-grafana/checkClients.sh &
