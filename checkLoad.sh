#!/bin/sh

# Checks the 1m, 5m and 15m CPU load and the uptime. Can be extended to also check the
# number of running CPU processes and last process ID.

. './common.sh'

load=$(cat /proc/loadavg)
load1=$(echo "$load" | awk '{print $1}')
load5=$(echo "$load" | awk '{print $2}')
load15=$(echo "$load" | awk '{print $3}')
#proc_run=$(echo "$load" | awk '{print $4}' | awk -F'/' '{print $1}')
#proc_total=$(echo "$load" | awk '{print $4}' | awk -F'/' '{print $2}')
#last_pid=$(echo "$load" | awk '{print $5}')
uptime=$(awk '{print $1}' /proc/uptime)

mqtt_publish -g 'load' -n '1m' -s "$load1" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'load' -n '5m' -s "$load5" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'load' -n '15m' -s "$load15" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic",'
mqtt_publish -g 'load' -n 'uptime' -s "$uptime" -o '"ic":"mdi:clock","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"s",'
#mqtt_publish -g 'processes' -n 'running' -s "$proc_run" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
#mqtt_publish -g 'processes' -n 'existing' -s "$proc_total" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
#mqtt_publish -g 'processes' -n 'last ID' -s "$last_pid" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'
