#!/bin/sh

. "${SCRIPTPATH}variables.sh"

connections=$(cat /proc/net/nf_conntrack)
tcp=$(echo "$connections" | grep ipv4 | grep -c tcp)
udp=$(echo "$connections" | grep ipv4 | grep -c udp)
icmp=$(echo "$connections" | grep ipv4 | grep -c icmp)
total=$(echo "$connections" | grep -c ipv4)

mqtt_publish -e "connections TCP count" -s "$tcp" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "connections UDP count" -s "$udp" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "connections ICMP count" -s "$icmp" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "connections total count" -s "$total" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
