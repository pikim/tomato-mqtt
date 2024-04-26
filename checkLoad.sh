#!/bin/sh

. variables.sh

load=$(cat /proc/loadavg)
load1=$(echo "$load" | awk '{print $1}')
load5=$(echo "$load" | awk '{print $2}')
load15=$(echo "$load" | awk '{print $3}')
proc_run=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $1}')
proc_total=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $2}')
last_pid=$(echo "$load" | awk '{print $5}')
uptime=$(awk '{print $1}' /proc/uptime)

mqtt_publish -e "load 1m" -s "$load1" -d '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "load 5m" -s "$load5" -d '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "load 15m" -s "$load15" -d '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "uptime" -s "$uptime" -d '"icon": "mdi:clock", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "s",'
#mqtt_publish -e "processes running" -s "$proc_run" -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "processes existing" -s "$proc_total" -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "last process ID" -s "$last_pid" -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
