#!/bin/sh

# Checks the number of bytes transferred on each interface. Ignores all interfaces from
# `/sys/class/net` which were added to the variable `ignore` (space separated) below.
# `listInterfaces.sh` shows a list of the interfaces.

. './common.sh'

ignore='dpsta ifb0 ifb1 ifb2 ifb3'
echo "Ignoring interfaces: $ignore"

for i in $(ls -A /sys/class/net/); do
    ## skip interfaces from ignore list
    if echo "$ignore" | grep -q "$i" 2>/dev/null; then
        continue
    fi

    rx=0
    tx=0
    rx=$(cat "/sys/class/net/${i}/statistics/rx_bytes")
    tx=$(cat "/sys/class/net/${i}/statistics/tx_bytes")

    i="${i//./_}"
    mqtt_publish -g 'network' -n "$i receive" -s "$rx" -o '"ic":"mdi:server-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
    mqtt_publish -g 'network' -n "$i transmit" -s "$tx" -o '"ic":"mdi:server-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
done
