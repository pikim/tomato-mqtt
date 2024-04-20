#!/bin/sh

source variables.sh

googleping=`ping -c 10 www.google.com | tail -2`
packet=`echo "$googleping" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+'`
google=`echo "$googleping" | grep "round-trip" | cut -d " " -f 4 | cut -d "/" -f 1`

mqtt_publish "ping google packetloss" $packet '"icon": "mdi:percent", "state_class": "measurement", "unit_of_meas": "%", '
mqtt_publish "ping google latency" $google '"icon": "mdi:timer-outline", "state_class": "measurement", "unit_of_meas": "ms", '
