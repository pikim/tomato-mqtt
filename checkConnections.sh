#!/bin/sh

source /jffs/tomato-grafana/variables.sh

connections=`cat /proc/net/nf_conntrack`
tcp=`echo "$connections" | grep ipv4 | grep tcp | wc -l`
udp=`echo "$connections" | grep ipv4 | grep udp | wc -l`
icmp=`echo "$connections" | grep ipv4 | grep icmp | wc -l`
total=`echo "$connections" | grep ipv4 | wc -l`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'connections.tcp.number value='$tcp
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'connections.udp.number value='$udp
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'connections.icmp.number value='$icmp
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'connections.total value='$total
