#!/bin/sh

# Checks the dnsmasq.leases file for known clients and tries to determine their
# connectivity state by pinging them.

. './common.sh'

leases_file='/var/lib/misc/dnsmasq.leases'
integration='binary_sensor'

## remove the *.handled file
rm -f "${file_prefix}.handled"
sync


## get the device ID and all its entities with an ip_address
leases=$(jq 'select(.ip_address != null)' "$entity_file")
## processed leases are removed from $leases, so only the obsolete leases remain in the end


## Process the active clients
## Extract relevant data from json, eventually delete entity first, ping client and publish new state
## $1: the name of the client as defined in the FreshTomato interface
## $2: the IP address of the client which has to be pinged
process_active_clients(){
    client_name="$1"
    client_addr="$2"

    ## ping client and parse data
    ping_result=$(ping -c3 -w1 "$client_addr" | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep 'packet loss' | grep -o '[0-9]\+')

    ## prepare and publish state
    state='ON'
    [ "$ping_loss" = '100' ] && state='OFF'
    echo "Publishing $client_name ($client_addr): $state"
    mqtt_publish -g 'leases' -n "$client_name" -f "$client_name" -i "$integration" -s "$state" -o '"dev_cla":"connectivity",'

    ## fetch internal results from mqtt_publish
    unique_id="$_unique_id"
    cfg_topic="$_cfg_topic"

    ## fetch meta data by unique_id name
    meta=$(echo "$leases" | jq -r "select(.uid == \"$unique_id\")")
    address=$(echo "$meta" | jq -r '.ip_address')
    uid=$(echo "$meta" | jq -r '.uid')
#    echo "$meta => $address => $uid"

    ## remember that this uid was already processed
    echo "$uid" >> "${file_prefix}.lease_uid"

    ## update IP address if it has changed
    if [ "$address" != "$client_addr" ]; then
        echo "Updating IP of $client_name to $client_addr"
        mqtt_publish -g 'leases' -n "$client_name" -f "$client_name" -i "$integration" -a "\"ip_address\":\"$client_addr\",\"discovery\":\"$cfg_topic\"" -o '"dev_cla":"connectivity",'
    fi
}


## Process the inactive clients
## Relevant data is already available, ping client and eventually delete entity
## $1: the name of the client as fetched from Home Assistant
## $2: the IP address of the client which has to be pinged
process_inactive_clients(){
    discovery="$1"
    address="$2"
    uid="$3"

    ## ping client and parse data
    ping_result=$(ping -c3 -w1 "$address" | tail -2)
    ping_loss=$(echo "$ping_result" | tr ',' '\n' | grep 'packet loss' | grep -o '[0-9]\+')

    ## prepare state and eventually delete the entity
    state='ON'
    [ "$ping_loss" = '100' ] && state='OFF'
    if [ "$state" = 'OFF' ]; then
        if [ -n "$discovery" ]; then
            echo "Deleting inactive $discovery"
            mqtt_publish -g 'na' -n 'na' -i 'na' -c "$discovery" -d true
        else
            echo "Can't delete $uid. Topic name is missing."
        fi
    fi
}


## get and transmit the number of leases first
count=$(wc -l "$leases_file" | awk '{print $1}')
mqtt_publish -g 'leases' -n 'count' -s "$count" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic",'


## iterate over active leases from dnsmasq file
echo 'Starting to ping active clients'
while IFS='' read -r p || [ -n "$p" ]
do
#    printf '%s\n' "$p"
    client_addr=$(echo "$p" | awk '{print $3}')
    client_name=$(echo "$p" | awk '{print $4}')

    process_active_clients "$client_name" "$client_addr" &
done < "$leases_file"

## wait for asynchronous processes to be finished
wait
echo 'Finished pinging of active clients'


## extract inactive leases received from Home Assistant (*.lease_uid file)
while IFS='' read -r unique_id || [ -n "$unique_id" ]
do
    leases=$(echo "$leases" | jq -r "select(.uid != \"$unique_id\")")
done < "${file_prefix}.lease_uid"


## iterate over remaining inactive leases
echo 'Starting to ping inactive clients'
echo "$leases" | jq -c '.' | while read -r lease; do
#    echo "$lease"
    discovery=$(echo "$lease" | jq -r '.discovery')
    address=$(echo "$lease" | jq -r '.ip_address')
    uid=$(echo "$lease" | jq -r '.uid')

    process_inactive_clients "$discovery" "$address" "$uid" &
done

## wait for asynchronous processes to be finished
#wait
echo 'Finished pinging of inactive clients'
