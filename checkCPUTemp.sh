#!/bin/sh

source /jffs/tomato-grafana/variables.sh

cpuTemp=`cat /proc/dmu/temperature  | grep -o '[0-9]\+'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'temp.cpu.degrees value='$cpuTemp
