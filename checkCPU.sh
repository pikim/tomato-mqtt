#!/bin/sh

# Checks the CPU temperature and CPU usage in percent. Should not be executed in parallel
# with the other script as its result will be distorted otherwise.

. './common.sh'

read -r cpu_name user_n nice_n sys_n idle_n iow_n irq_n sirq_n stl_n gst_n g_nice_n < /proc/stat
total_n=$((user_n + nice_n + sys_n + idle_n + iow_n + irq_n + sirq_n + stl_n + gst_n + g_nice_n))

if [ -f "$cpu_stats_file" ]; then
    read -r total_o idle_o < "$cpu_stats_file"

    diff_total=$((total_n - total_o))
    diff_idle=$((idle_n - idle_o))

    if [ "$diff_total" -gt 0 ]; then
        usage=$(( ((1000 * (diff_total - diff_idle)) / diff_total + 5) / 10 ))
        mqtt_publish -g 'CPU' -n 'usage' -s "$usage" -o '"ic":"mdi:percent","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'
    fi
fi

echo "$total_n $idle_n" > "$cpu_stats_file"


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
