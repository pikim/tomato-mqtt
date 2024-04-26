#!/bin/sh

. variables.sh

for i in $disks; do
    used=0
    free=0
    total=$(df | grep "$i" | awk '{print $2}')
    used=$(df | grep "$i" | awk '{print $3}')
    free=$(df | grep "$i" | awk '{print $4}')
    part=$(df | grep "$i" | awk -F"/" '{ print $NF }')

    ## skip invalid disk names
    [ "$part" = "" ] && continue

    mqtt_publish -e "disk $part used" -s "$used" -d '"icon": "mdi:harddisk", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
    mqtt_publish -e "disk $part free" -s "$free" -d '"icon": "mdi:harddisk", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
    mqtt_publish -e "disk $part total" -s "$total" -d '"icon": "mdi:harddisk", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
done
