#!/bin/sh

# Checks the connectivity of hosts by pinging them. Add the hosts of interest to the
# variable `hosts` (space separated) in `config.sh`

. './common.sh'

ping_host(){
    host_name="$1"
    ping_result=$(ping -c 10 "$host_name" | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep 'packet loss' | grep -o '[0-9]\+')
    ping_time=$(echo "$ping_result" | grep 'round-trip' | cut -d " " -f 4 | cut -d '/' -f 1)

    host_name="${host_name//./_}"
    mqtt_publish -g 'ping' -n "$host_name loss" -s "$ping_loss" -o '"ic":"mdi:percent","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'
    mqtt_publish -g 'ping' -n "$host_name time" -s "$ping_time" -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"ms"'
}

for i in $hosts; do
    ping_host "$i" &
done
