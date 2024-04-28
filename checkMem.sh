#!/bin/sh

. "${SCRIPTPATH}variables.sh"

mem=$(cat /proc/meminfo)
total=$(echo "$mem" | grep ^MemTotal | awk '{print $2}')
free=$(echo "$mem" | grep ^MemFree | awk '{print $2}')
used=$(( total - free ))
buffers=$(echo "$mem" | grep ^Buffers | awk '{print $2}')
cached=$(echo "$mem" | grep ^Cached: | awk '{print $2}')
active=$(echo "$mem" | grep ^Active: | awk '{print $2}')
inactive=$(echo "$mem" | grep ^Inactive: | awk '{print $2}')

mqtt_publish -e "RAM free" -s "$free" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
mqtt_publish -e "RAM used" -s "$used" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
mqtt_publish -e "RAM total" -s "$total" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
#mqtt_publish -e "RAM active" -s "$active" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
#mqtt_publish -e "RAM cached" -s "$cached" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
#mqtt_publish -e "RAM buffers" -s "$buffers" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'
#mqtt_publish -e "RAM inactive" -s "$inactive" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB",'

nvram=$(nvram show 2>&1 1>/dev/null | tr -cd ' 0-9')
nv_used=$(echo "$nvram" | awk '{print $1}')
nv_free=$(echo "$nvram" | awk '{print $2}')
nv_total=$(( nv_used + nv_free ))

mqtt_publish -e "NVRAM free" -s "$nv_free" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
mqtt_publish -e "NVRAM used" -s "$nv_used" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
mqtt_publish -e "NVRAM total" -s "$nv_total" -o '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B",'
