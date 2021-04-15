#!/bin/sh

source /jffs/tomato-grafana/variables.sh

for i in `\ls -A /sys/class/net/`; do
 rx=0
 tx=0
 rx=`cat /sys/class/net/$i/statistics/rx_bytes`
 tx=`cat /sys/class/net/$i/statistics/tx_bytes`
 curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'network.'$i'.receive.bytes value='$rx
 curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'network.'$i'.transmit.bytes value='$tx
done
