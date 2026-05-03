#!/bin/sh

# Checks the connectivity of hosts by pinging them. Add the hosts of interest to the
# variable `hosts` (space separated) in `config.sh`

. './common.sh'

ping_host(){
    host_name="$1"

    stats=$(ping -c 10 "$host_name" | awk '
        /packet loss/ {
            match($0, /[0-9]+%/)
            loss = substr($0, RSTART, RLENGTH-1)
        }
        /round-trip|rtt/ {
            split($4, a, "/")
            time = a[1]
        }
        END { print loss, time }
    ')

    read -r ping_loss ping_time <<EOF
$stats
EOF

    [ -z "$ping_loss" ] && ping_loss=100
    [ -z "$ping_time" ] && ping_time=0

    tech_name=$(echo "$host_name" | tr '.' '_')
    mqtt_publish -g 'ping' -n "$tech_name loss" -f "ping $host_name loss" -s "$ping_loss" -o '"ic":"mdi:percent","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'
    mqtt_publish -g 'ping' -n "$tech_name time" -f "ping $host_name time" -s "$ping_time" -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"ms"'
}

for i in $hosts; do
    ping_host "$i" &
done
