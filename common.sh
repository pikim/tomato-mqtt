#!/bin/sh

# Holds the base functionality and variables for all the other scripts.

## read custom configuration
. "./config.sh"

## MQTT topic settings
retain=""
#retain="-r"
prefix="FreshTomato"
device=$(nvram get t_fix1)
version=$(nvram get os_version)
ip_addr=$(nvram get lan_ipaddr)

## set https or http as protocol
[ "$(nvram get https_enable)" = "1" ] && cfg_url="https://$ip_addr"
[ "$(nvram get http_enable)" = "1" ] && cfg_url="http://$ip_addr"

## file settings
file_prefix="/tmp/${prefix}_${device}"
entity_file="${file_prefix}.json"
twig_file="${file_prefix}.twig"
pid_file="${file_prefix}.pid"


## source everything except the variables only once
[ -n "${sourced_variables_sh+x}" ] && return
sourced_variables_sh=true


## Fetch device entities from Home Assistant
fetch_entities(){
    echo "Fetching device entities from Home Assistant"
    ## locking taken from https://gist.github.com/didenko/a92beec14ce2ca1c98f3
    exec 221>"${pid_file}"
    flock --exclusive 221
    echo ${$}>&221

    ## update device_name in template.twig
    if [ ! -e "$twig_file" ]; then
        sed "s/{% set device_name =.*/{% set device_name = '$device' %}/g" "template.twig" > "$twig_file"
    fi

    ## request entities
    curl -X POST "http://${ra_addr}:${ra_port}/api/template" \
        -H "Authorization: Bearer $ra_token" \
        -H "Content-Type: application/json" \
        -d @"$twig_file" \
        > "$entity_file"

    ## replace single with double quotes and format file
    sed -i "s/'/\"/g" "$entity_file"
    content=$(jq '.' "$entity_file") && echo "$content" > "$entity_file"

    ## critical part finished, unlock
    flock --unlock 221
}

## execute function
fetch_entities


## Publish an entity state
## -s|--state: entity value
##      e.g. '8'.
## -d|--delete: true to delete an entity
## -e|--entity: entity name as string
##      e.g. 'CPU usage'. Spaces will be replaced with underscores
## -f|--friendly: friendly name as string
##      e.g. 'CPU usage'
## -o|--options: additional information for MQTT discovery, as comma terminated string (optional)
##      e.g. '"icon": "mdi:numeric", "state_class": "measurement", "device_class": "temperature", "unit_of_meas": "°C", "entity_category": "diagnostic", '
## -a|--attributes: attributes for the entity (optional)
##      e.g. '"rule_name": "Block Server"'
## -i|--integration: integration type (optional, default is 'sensor')
##      e.g. "binary_sensor", "sensor" or "switch"
mqtt_publish(){
    state=""
    entity=""
    options=""
    friendly=""
    attributes=""
    integration="sensor"
    delete=false

    ## Loop through the provided arguments
    ## taken from https://linuxsimply.com/bash-scripting-tutorial/parameters/named-parameters/
    while [ "$#" -gt 0 ]; do
        case $1 in
            -s|--state) state="$2" ## Store the first name argument
                shift;;
            -d|--delete) delete="$2" ## Store the first name argument
                shift;;
            -e|--entity) entity="$2" ## Store the first name argument
                shift;;
            -o|--options) options="$2" ## Store the first name argument
                shift;;
            -f|--friendly) friendly="$2" ## Store the first name argument
                shift;;
            -a|--attributes) attributes="$2" ## Store the first name argument
                shift;;
            -i|--integration) integration="$2" ## Store the first name argument
                shift;;
            *) echo "Unknown parameter passed: $1" ## Display error for unknown parameter
        esac
        shift ## Move to the next argument
    done

    if [ "$friendly" = "" ]; then
        ## no friendly name given, use entity name
        friendly="$entity"
    fi
    entity="${entity// /_}"

    ## define topics once and reuse them
    cfg_topic="homeassistant/${integration}/${entity}/config"
    attr_topic="homeassistant/${integration}/${entity}/attributes"
    state_topic="homeassistant/${integration}/${entity}/state"

    if [ "$delete" = true ]; then
        mosquitto_pub $retain -h "$addr" -p "$port" -u "$username" -P "$password" -t "$cfg_topic" -m ""
        return
    fi

    if ! grep -Fiqx "${integration}.${device}_${entity}" "$entity_file"; then
        ## create variables
        object_id="${device}_${entity}"
        unique_id="${prefix}_${device}_${entity}"

        ## string not found in file, entity wasn't registered yet
        ## announce entity
#        echo "$cfg_topic"
#        echo "{\"name\": \"${friendly}\", \"state_topic\": \"${state_topic}\", \"json_attributes_topic\": \"${attr_topic}\", ${options} \"object_id\": \"${object_id}\", \"unique_id\": \"${unique_id}\", \"device\": {\"identifiers\": [\"${prefix} ${device}\"], \"name\": \"${device}\", \"configuration_url\": \"${cfg_url}\", \"sw_version\": \"${version}\"}}"
        mosquitto_pub $retain -h "$addr" -p "$port" -u "$username" -P "$password" -t "$cfg_topic" -m "{\"name\": \"${friendly}\", \"state_topic\": \"${state_topic}\", \"json_attributes_topic\": \"${attr_topic}\", ${options} \"object_id\": \"${object_id}\", \"unique_id\": \"${unique_id}\", \"device\": {\"identifiers\": [\"${prefix} ${device}\"], \"name\": \"${device}\", \"configuration_url\": \"${cfg_url}\", \"sw_version\": \"${version}\"}}"
    fi

    if [ -n "$state" ]; then
        ## send entity state via MQTT
        mosquitto_pub $retain -h "$addr" -p "$port" -u "$username" -P "$password" -t "$state_topic" -m "$state"

        ## send entity data via REST, UNTESTED!!!
#        curl -X POST -H "Authorization: Bearer $ra_token" -H "Content-Type: application/json" -d "{\"state\":\"$state\"}" "http://${ra_addr}:${ra_port}/api/states/${integration}.${device}_${entity}"
    fi

    if [ -n "$attributes" ]; then
        ## send entity attributes via MQTT
        mosquitto_pub $retain -h "$addr" -p "$port" -u "$username" -P "$password" -t "$attr_topic" -m "$attributes"
    fi
}

## optional='
## "icon": "mdi:numeric",
## "state_class": "measurement",
## "device_class": "temperature",
## "unit_of_meas": "°C",
## "entity_category": "diagnostic",
## '


## Get an entity state
## -e|--entity: entity name as string
##      e.g. 'CPU usage'. Spaces will be replaced with underscores
## -p|--property: property to read (optional, default is 'state')
##      e.g. 'last_changed', state, ...
## -i|--integration: integration type (optional, default is 'sensor')
##      e.g. "binary_sensor", "sensor", "switch", ...
rest_get(){
    entity=""
    property=""
    integration="sensor"

    ## Loop through the provided arguments
    ## taken from https://linuxsimply.com/bash-scripting-tutorial/parameters/named-parameters/
    while [ "$#" -gt 0 ]; do
        case $1 in
            -e|--entity) entity="$2" ## Store the first name argument
                shift;;
            -p|--property) property="$2" ## Store the first name argument
                shift;;
            -i|--integration) integration="$2" ## Store the first name argument
                shift;;
            *) echo "Unknown parameter passed: $1" ## Display error for unknown parameter
        esac
        shift ## Move to the next argument
    done

    entity="${entity// /_}"

#    echo "Authorization: Bearer $ra_token"
#    echo "http://${ra_addr}:${ra_port}/api/states/${integration}.${device}_${entity}"
    curl -X GET -s -H "Authorization: Bearer $ra_token" -H "Content-Type: application/json" "http://${ra_addr}:${ra_port}/api/states/${integration}.${device}_${entity}" | jq -r ".${property}"
}

## curl get response:
## {"entity_id":"sensor.r6400v2_clients_count","state":"12","attributes":{},"last_changed":"2024-04-22T21:17:06.724753+00:00","last_updated":"2024-04-22T21:17:06.724753+00:00","context":{"id":"01HW3TPVS4RYPXA3XVK0CG36B8","parent_id":null,"user_id":"0a5940fde5564d5b9e4baf64acdd78a7"}}
