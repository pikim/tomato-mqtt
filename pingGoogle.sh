#!/bin/sh

. "${SCRIPTPATH}/variables.sh"

googleping=$(ping -c 10 www.google.com | tail -2)
packet=$(echo "$googleping" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')
google=$(echo "$googleping" | grep "round-trip" | cut -d " " -f 4 | cut -d "/" -f 1)

mqtt_publish -e "ping google packetloss" -s "$packet" -o '"icon": "mdi:percent", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "%",'
mqtt_publish -e "ping google latency" -s "$google" -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "ms",'
