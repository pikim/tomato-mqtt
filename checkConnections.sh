#!/bin/sh

source variables.sh

connections=`cat /proc/net/nf_conntrack`
tcp=`echo "$connections" | grep ipv4 | grep tcp | wc -l`
udp=`echo "$connections" | grep ipv4 | grep udp | wc -l`
icmp=`echo "$connections" | grep ipv4 | grep icmp | wc -l`
total=`echo "$connections" | grep ipv4 | wc -l`

mqtt_publish "connections TCP count" $tcp '"icon": "mdi:numeric", "state_class": "measurement", '
mqtt_publish "connections UDP count" $udp '"icon": "mdi:numeric", "state_class": "measurement", '
mqtt_publish "connections ICMP count" $icmp '"icon": "mdi:numeric", "state_class": "measurement", '
mqtt_publish "connections total count" $total '"icon": "mdi:numeric", "state_class": "measurement", '
