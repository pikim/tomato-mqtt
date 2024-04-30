#!/bin/sh

. "${SCRIPTPATH}variables.sh"

for i in $hosts; do
    ping_host="$i"
    ping_result=$(ping -c 10 $ping_host | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')
    ping_time=$(echo "$ping_result" | grep "round-trip" | cut -d " " -f 4 | cut -d "/" -f 1)

    mqtt_publish -e "ping ${ping_host//./_} loss" -s "$ping_loss" -o '"icon": "mdi:percent", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "%",'
    mqtt_publish -e "ping ${ping_host//./_} time" -s "$ping_time" -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "ms",'
done
