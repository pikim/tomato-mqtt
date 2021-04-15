#!/bin/sh

source /jffs/tomato-grafana/variables.sh

clients=`arp -an | grep -v vlan2 | wc -l`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'client.count value='$clients
