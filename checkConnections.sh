#!/bin/sh

source variables.sh

connections=`cat /proc/net/nf_conntrack`
tcp=`echo "$connections" | grep ipv4 | grep tcp | wc -l`
udp=`echo "$connections" | grep ipv4 | grep udp | wc -l`
icmp=`echo "$connections" | grep ipv4 | grep icmp | wc -l`
total=`echo "$connections" | grep ipv4 | wc -l`

mqtt_publish -e "connections TCP count" -s $tcp -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish -e "connections UDP count" -s $udp -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish -e "connections ICMP count" -s $icmp -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish -e "connections total count" -s $total -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
