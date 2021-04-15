#!/bin/sh
/jffs/dd-wrt-grafana/checkBandwidthInterface.sh &
/jffs/dd-wrt-grafana/checkConnections.sh &
/jffs/dd-wrt-grafana/pingGoogle.sh &
/jffs/dd-wrt-grafana/checkLoad.sh &
/jffs/dd-wrt-grafana/checkCPUTemp.sh &
/jffs/dd-wrt-grafana/checkMem.sh &
/jffs/dd-wrt-grafana/checkCPU.sh &
/jffs/dd-wrt-grafana/checkClients.sh &
