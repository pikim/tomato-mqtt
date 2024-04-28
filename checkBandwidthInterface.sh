#!/bin/sh

. "${SCRIPTPATH}/variables.sh"

ignore="dpsta ifb0 ifb1 ifb2 ifb3"

for i in $(ls -A /sys/class/net/); do
    ## skip interfaces from ignore list
    [[ "$ignore" == *"$i"* ]] && continue

    rx=0
    tx=0
    rx=$(cat /sys/class/net/"$i"/statistics/rx_bytes)
    tx=$(cat /sys/class/net/"$i"/statistics/tx_bytes)

    mqtt_publish -e "network ${i//./_} receive" -s "$rx" -o '"icon": "mdi:server-network", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
    mqtt_publish -e "network ${i//./_} transmit" -s "$tx" -o '"icon": "mdi:server-network", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
done
