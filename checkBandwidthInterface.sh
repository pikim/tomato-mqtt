#!/bin/sh

source variables.sh

for i in `\ls -A /sys/class/net/`; do
    rx=0
    tx=0
    rx=`cat /sys/class/net/$i/statistics/rx_bytes`
    tx=`cat /sys/class/net/$i/statistics/tx_bytes`

    mqtt_publish "network ${i//./_} receive" $rx '"icon": "mdi:server-network", "state_class": "measurement", "device_class": "data_size", "unit_of_meas": "B", '
    mqtt_publish "network ${i//./_} transmit" $tx '"icon": "mdi:server-network", "state_class": "measurement", "device_class": "data_size", "unit_of_meas": "B", '
done
