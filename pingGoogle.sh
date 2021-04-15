#!/bin/sh

source /jffs/tomato-grafana/variables.sh

googleping=`ping -c 10 www.google.com | tail -2`
packet=`echo "$googleping" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+'`
google=`echo "$googleping" |grep "round-trip" | cut -d " " -f 4 | cut -d "/" -f 1`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'ping.google.packetloss.percent value='$packet
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'ping.google.latency value='$google
