#!/bin/sh

source variables.sh

load=`cat /proc/loadavg`
load1=`echo "$load" | awk '{print $1}'`
load5=`echo "$load" | awk '{print $2}'`
load15=`echo "$load" | awk '{print $3}'`
proc_run=`echo "$load" | awk '{print $4}' | awk -F '/' '{print $1}'`
proc_total=`echo "$load" | awk '{print $4}' | awk -F '/' '{print $2}'`
uptime=`cat /proc/uptime | awk '{print $1}'`

mqtt_publish "load 1m" $load1 '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "load 5m" $load5 '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "load 15m" $load15 '"icon": "mdi:cpu-64-bit", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "uptime" $uptime '"icon": "mdi:clock", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "s", '
mqtt_publish "processes running" $proc_run '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "processes existing" $proc_total '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
