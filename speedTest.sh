#!/bin/sh

. "${SCRIPTPATH}/variables.sh"

[ ! -x ../speedtest/speedtest ] && exit

result=$(../speedtest/speedtest -f csv --accept-license --accept-gdpr)
ping=$(echo "$result" | awk -F\" '{print $6}')
jitter=$(echo "$result" | awk -F\" '{print $8}')
loss=$(echo "$result" | awk -F\" '{print $10}')
down=$(echo "$result" | awk -F\" '{print $12}')
up=$(echo "$result" | awk -F\" '{print $14}')
#url=$(echo "$result" | awk -F\" '{print $29}')

# calculate kbps
down=$((down/125))
up=$((up/125))

mqtt_publish -e "speedtest ping" -s "$ping" -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "ms",'
mqtt_publish -e "speedtest upload" -s "$up" -o '"icon": "mdi:speedometer", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "kbit/s",'
mqtt_publish -e "speedtest download" -s "$down" -o '"icon": "mdi:speedometer", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "kbit/s",'
#mqtt_publish -e "speedtest URL" -i "text" -s "$url" -o '"icon": "mdi:web", "entity_category": "diagnostic",'
