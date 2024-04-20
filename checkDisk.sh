#!/bin/sh

source variables.sh

for i in $disks; do
    used=0
    free=0
    used=`df | grep \ $i$ | awk '{print $3}'`
    free=`df | grep \ $i$ | awk '{print $4}'`
    part=`df | grep \ $i$ | awk -F"/" '{ print $NF }'`

    mqtt_publish "disk $part used" $used '"icon": "mdi:harddisk", "state_class": "measurement", "device_class": "data_size", "unit_of_meas": "B", '
    mqtt_publish "disk $part free" $free '"icon": "mdi:harddisk", "state_class": "measurement", "device_class": "data_size", "unit_of_meas": "B", '
done
