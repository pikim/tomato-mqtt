#!/bin/sh

# Checks the number of open connections.

. './common.sh'

read tcp udp icmp total <<EOF
$(awk '/ipv4/ {
    total++
    if ($0 ~ /tcp/) t++
    else if ($0 ~ /udp/) u++
    else if ($0 ~ /icmp/) i++
}
END { print t+0, u+0, i+0, total+0 }' /proc/net/nf_conntrack)
EOF

mqtt_publish -g 'connections' -n 'TCP count' -s "$tcp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
mqtt_publish -g 'connections' -n 'UDP count' -s "$udp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
mqtt_publish -g 'connections' -n 'ICMP count' -s "$icmp" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
mqtt_publish -g 'connections' -n 'total count' -s "$total" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
