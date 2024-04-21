#!/bin/sh

source variables.sh

[ ! -x ../speedtest/speedtest ] && exit

result=`../speedtest/speedtest -f csv --accept-license --accept-gdpr`
ping=`echo "$result" | awk -F\" '{print $6}'`
jitter=`echo "$result" | awk -F\" '{print $8}'`
loss=`echo "$result" | awk -F\" '{print $10}'`
down=`echo "$result" | awk -F\" '{print $12}'`
up=`echo "$result" | awk -F\" '{print $14}'`

# calculate kbps
down=$(($down/125))
up=$(($up/125))

mqtt_publish "speedtest ping" $ping '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "ms", '
mqtt_publish "speedtest upload" $up '"icon": "mdi:speedometer", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "kbit/s", '
mqtt_publish "speedtest download" $down '"icon": "mdi:speedometer", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "kbit/s", '
