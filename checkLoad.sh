#!/bin/sh

# Checks the 1m, 5m and 15m CPU load and the uptime. Can be extended to also check the
# number of running CPU processes and last process ID.

. './common.sh'

read -r load1 load5 load15 entities last_pid < /proc/loadavg
run_procs=${entities%/*}
total_procs=${entities#*/}

mqtt_publish -g 'CPU' -n '1m' -s "$load1" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic"'
mqtt_publish -g 'CPU' -n '5m' -s "$load5" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic"'
mqtt_publish -g 'CPU' -n '15m' -s "$load15" -o '"ic":"mdi:cpu-64-bit","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'processes' -n 'running' -s "$run_procs" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'processes' -n 'existing' -s "$total_procs" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'processes' -n 'last ID' -s "$last_pid" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'

read -r uptime_total uptime_idle < /proc/uptime
mqtt_publish -g 'CPU' -n 'uptime' -s "$uptime_total" -o '"ic":"mdi:clock","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"s"'
#mqtt_publish -g 'CPU' -n 'uptime idle' -s "$uptime_idle" -o '"ic":"mdi:clock","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"s"'
