#!/bin/sh

include /jffs/tomato-grafana/variables.sh

for i in $disks; do
 used=0
 free=0
 used=`df | grep \ $i$ | awk '{print $3}'`
 free=`df | grep \ $i$ | awk '{print $4}'`
 curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'disk.'$i'.used value='$used
 curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'disk.'$i'.free value='$free
done
