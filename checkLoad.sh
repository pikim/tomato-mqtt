#!/bin/sh

source /jffs/tomato-grafana/variables.sh

load=`cat /proc/loadavg`
load1=`echo "$load" | awk '{print $1}'`
load5=`echo "$load" | awk '{print $2}'`
load15=`echo "$load" | awk '{print $3}'`
proc_run=`echo "$load" | awk '{print $4}' | awk -F '/' '{print $1}'`
proc_total=`echo "$load" | awk '{print $4}' | awk -F '/' '{print $2}'`
uptime=`cat /proc/uptime | awk '{print $1}'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.load_one.number value='$load1
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.load_five.number value='$load5
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.load_fifteen.number value='$load15
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.proc_run.number value='$proc_run
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.proc_total.number value='$proc_total
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'load.uptime value='$uptime
