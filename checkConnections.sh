#!/bin/sh

# Checks the number of open connections.

. './common.sh'

connections=$(cat /proc/net/nf_conntrack)
tcp=$(echo "$connections" | grep ipv4 | grep -c tcp)
udp=$(echo "$connections" | grep ipv4 | grep -c udp)
icmp=$(echo "$connections" | grep ipv4 | grep -c icmp)
total=$(echo "$connections" | grep -c ipv4)

mqtt_publish -g 'connections' -n 'TCP count' -s "$tcp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'connections' -n 'UDP count' -s "$udp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'connections' -n 'ICMP count' -s "$icmp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'connections' -n 'total count' -s "$total" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
