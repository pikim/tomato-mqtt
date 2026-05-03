#!/bin/sh

# Checks the CPU temperature and CPU usage in percent. Should not be executed in parallel
# with the other script as its result will be distorted otherwise.

. './common.sh'

read -r cpu_line_old < /proc/stat
sleep 4
read -r cpu_line_new < /proc/stat

set -- $cpu_line_old
user_o=$2; nice_o=$3; sys_o=$4; idle_o=$5; iow_o=$6; irq_o=$7; sirq_o=$8; stl_o=$9; gst_o=$10; g_nice_o=$11

set -- $cpu_line_new
user_n=$2; nice_n=$3; sys_n=$4; idle_n=$5; iow_n=$6; irq_n=$7; sirq_n=$8; stl_n=$9; gst_n=$10; g_nice_n=$11

total_old=$((user_o + nice_o + sys_o + idle_o + iow_o + irq_o + sirq_o + stl_o + gst_o + g_nice_o))
total_new=$((user_n + nice_n + sys_n + idle_n + iow_n + irq_n + sirq_n + stl_n + gst_n + g_nice_n))

diff_total=$((total_new - total_old))
diff_idle=$((idle_n - idle_o))

usage=$(( ((1000 * (diff_total - diff_idle)) / diff_total + 5) / 10 ))
mqtt_publish -g 'CPU' -n 'usage' -s "$usage" -o '"ic":"mdi:percent","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'

cpuTemp=$(grep -o '[0-9]\+' /proc/dmu/temperature)
mqtt_publish -g 'CPU' -n 'temperature' -s "$cpuTemp" -o '"ic":"mdi:thermometer","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"temperature","unit_of_meas":"°C"'

#mqtt_publish -g 'CPU'' -n 'IRQ' -s $irq -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'user' -s $user -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'nice' -s $nice -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'idle' -s $idle -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'guest' -s $guest -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'steal' -s $steal -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'iowait' -s $iowait -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'system' -s $system -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'softirq' -s $softirq -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'guest nice' -s $guest_nice -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
