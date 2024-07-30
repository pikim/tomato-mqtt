#!/bin/sh

# Checks the dnsmasq.leases file for known clients and tries to determine their
# connectivity state by pinging them.

. "./common.sh"

integration="binary_sensor"
rm -f "${file_prefix}.handled"
sync


## get the device ID and all its entities with an ip_address
leases=$(jq ". | select(.ip_address != null)" "$entity_file")
## processed leases are removed from $leases, so only the obsolete leases remain in the end


## Process the active clients
## Extract relevant data from json, eventually delete entity first, ping client and publish new state
## $1: the name of the client as defined in the FreshTomato interface
## $2: the IP address of the client which has to be pinged
process_active_clients(){
    client_name="$1"
    client_addr="$2"

    ## fetch meta data by friendly name (including the device prefix) and remove the device prefix
    meta=$(echo "$leases" | jq -r ". | select(.friendly_name == \"$client_name\")")
    friendly=$(echo "$meta" | jq -r '.friendly_name')
    address=$(echo "$meta" | jq -r '.ip_address')
    entity=$(echo "$meta" | jq -r '.entity')

    ## remember that this entity was already processed
    echo "$entity" >> "${file_prefix}.handled"

    ## delete entity if it has the same name but a different address
    if [ "$friendly" = "$client_name" ]; then
        if [ "$address" != "$client_addr" ]; then
            echo "Deleting differing $client_name"
            mqtt_publish -e "$client_name" -i "$integration" -d true
        fi
    fi

    ## ping client and parse data
    ping_result=$(ping -c 5 "$client_addr" | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')

    ## prepare and publish state
    state="ON"
    [ "$ping_loss" = "100" ] && state="OFF"
    echo "Publishing $client_name ($client_addr): $state"
    mqtt_publish -e "$client_name" -i "$integration" -s "$state" -a "{\"ip_address\": \"$client_addr\"}" -o '"device_class": "connectivity",'
}


## Process the inactive clients
## Relevant data is already available, ping client and eventually delete entity
## $1: the name of the client as fetched from Home Assistant
## $2: the IP address of the client which has to be pinged
process_inactive_clients(){
    friendly="$1"
    address="$2"

    ## ping client and parse data
    ping_result=$(ping -c 5 "$address" | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep "packet loss" | grep -o '[0-9]\+')

    ## prepare state and eventually delete the entity
    state="ON"
    [ "$ping_loss" = "100" ] && state="OFF"
    if [ "$state" = "OFF" ]; then
        echo "Deleting inactive $friendly"
        mqtt_publish -e "$friendly" -i "$integration" -d true
    fi
}


## iterate over active leases from dnsmasq file
echo "Starting to ping active clients"
while IFS="" read -r p || [ -n "$p" ]
do
#    printf '%s\n' "$p"
    client_addr=$(echo "$p" | awk '{print $3}')
    client_name=$(echo "$p" | awk '{print $4}')

    process_active_clients "$client_name" "$client_addr" &
done < "/var/lib/misc/dnsmasq.leases"

## wait for asynchronous processes to be finished
wait
echo "Finished pinging of active clients"


## extract inactive leases received from Home Assistant (*.handled file)
while IFS="" read -r entity || [ -n "$entity" ]
do
    leases=$(echo "$leases" | jq -r ". | select(.entity != \"$entity\")")
done < "${file_prefix}.handled"


## iterate over remaining inactive leases
echo "Starting to ping inactive clients"
echo "$leases" | jq -c '.' | while read -r lease; do
#    echo "$lease"
    friendly=$(echo "$lease" | jq -r '.friendly_name')
    address=$(echo "$lease" | jq -r '.ip_address')

    process_inactive_clients "$friendly" "$address" &
done

## wait for asynchronous processes to be finished
#wait
echo "Finished pinging of inactive clients"

## remove the *.handled file
rm -f "${file_prefix}.handled"
