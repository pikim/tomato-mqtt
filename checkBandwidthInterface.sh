#!/bin/sh

# Checks the number of bytes transferred on each interface. Ignores all interfaces from
# `/sys/class/net` which were added to the variable `ignore` (space separated) below.
# `listInterfaces.sh` shows a list of the interfaces.

. "./common.sh"

ignore="dpsta ifb0 ifb1 ifb2 ifb3"

for i in $(ls -A /sys/class/net/); do
    ## skip interfaces from ignore list
    if echo "$ignore" | grep -q "$i" 2>/dev/null; then
        echo "Ignoring interface $i"
        continue
    fi

    rx=0
    tx=0
    rx=$(cat "/sys/class/net/${i}/statistics/rx_bytes")
    tx=$(cat "/sys/class/net/${i}/statistics/tx_bytes")

    i="${i//./_}"
    mqtt_publish -e "network $i receive" -s "$rx" -o '"icon": "mdi:server-network", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
    mqtt_publish -e "network $i transmit" -s "$tx" -o '"icon": "mdi:server-network", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
done
