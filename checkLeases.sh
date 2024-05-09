#!/bin/sh

. "${SCRIPTPATH}variables.sh"

ping_client(){
    client_name="$1"
    client_addr="$2"

    ping_result=$(ping -c 5 $client_addr | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')

    state="ON"
    [[ "$ping_loss" = "100" ]] && state="OFF"

    mqtt_publish -e "$client_name" -i "binary_sensor" -s "$state" -o '"device_class": "connectivity",'
}

while IFS="" read -r p || [ -n "$p" ]
do
#    printf '%s\n' "$p"
    client_addr=$(echo "$p" | awk '{print $3}')
    client_name=$(echo "$p" | awk '{print $4}')

    ping_client "$client_name" "$client_addr" &
done < "/var/lib/misc/dnsmasq.leases"
