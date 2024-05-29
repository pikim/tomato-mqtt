#!/bin/sh

# Checks the 1m, 5m and 15m CPU load and the uptime. Can be extended to also check the
# number of running CPU processes and last process ID.

. "./common.sh"

load=$(cat /proc/loadavg)
load1=$(echo "$load" | awk '{print $1}')
load5=$(echo "$load" | awk '{print $2}')
load15=$(echo "$load" | awk '{print $3}')
#proc_run=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $1}')
#proc_total=$(echo "$load" | awk '{print $4}' | awk -F '/' '{print $2}')
#last_pid=$(echo "$load" | awk '{print $5}')
uptime=$(awk '{print $1}' /proc/uptime)

mqtt_publish -e "load 1m" -s "$load1" -o '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "load 5m" -s "$load5" -o '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "load 15m" -s "$load15" -o '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic",'
mqtt_publish -e "uptime" -s "$uptime" -o '"icon": "mdi:clock", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "s",'
#mqtt_publish -e "processes running" -s "$proc_run" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "processes existing" -s "$proc_total" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "last process ID" -s "$last_pid" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
