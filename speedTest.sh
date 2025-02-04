#!/bin/sh

# Performs the OOKLA speedtest and determines download and upload speeds and the ping
# time.

. './common.sh'

[ ! -x '../speedtest/speedtest' ] && exit

result=$('../speedtest/speedtest' -f csv --accept-license --accept-gdpr)
ping=$(echo "$result" | awk -F'"' '{print $6}')
#jitter=$(echo "$result" | awk -F'"' '{print $8}')
#loss=$(echo "$result" | awk -F'"' '{print $10}')
down=$(echo "$result" | awk -F'"' '{print $12}')
up=$(echo "$result" | awk -F'"' '{print $14}')
#url=$(echo "$result" | awk -F'"' '{print $29}')

# calculate kbps
down=$((down/125))
up=$((up/125))

mqtt_publish -g 'speedtest' -n 'ping' -s "$ping" -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"ms"'
mqtt_publish -g 'speedtest' -n 'upload' -s "$up" -o '"ic":"mdi:speedometer","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"kbit/s"'
mqtt_publish -g 'speedtest' -n 'download' -s "$down" -o '"ic":"mdi:speedometer","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"kbit/s"'
#mqtt_publish -g 'speedtest' -n 'URL' -i 'text' -s "$url" -o '"ic":"mdi:web","ent_cat":"diagnostic"'
