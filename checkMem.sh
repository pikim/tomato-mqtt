#!/bin/sh

source /jffs/dd-wrt-grafana/variables.sh

mem=`cat /proc/meminfo`
total=`echo "$mem" | grep ^MemTotal | awk '{print $2}'`
free=`echo "$mem" | grep ^MemFree | awk '{print $2}'`
used=`echo $(( $total - $free ))`
buffers=`echo "$mem" | grep ^Buffers | awk '{print $2}'`
cached=`echo "$mem" | grep ^Cached: | awk '{print $2}'`
active=`echo "$mem" | grep ^Active: | awk '{print $2}'`
inactive=`echo "$mem" | grep ^Inactive: | awk '{print $2}'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.total.kilobytes value='$total
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.free.kilobytes value='$free
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.used.kilobytes value='$used
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.buffers.kilobytes value='$buffers
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.cached.kilobytes value='$cached
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.active.kilobytes value='$active
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'mem.inactive.kilobytes value='$inactive
