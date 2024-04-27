#!/bin/sh

## read custom configuration
. config.sh

## MQTT topic settings
prefix="FreshTomato"
device=$(nvram get t_fix1)
version=$(nvram get os_version)
ip_addr=$(nvram get lan_ipaddr)

[ "$(nvram get https_enable)" = "1" ] && cfg_url="https://$ip_addr"
[ "$(nvram get http_enable)" = "1" ] && cfg_url="http://$ip_addr"


## define file name and create file if it doesn't exist
entity_file="${prefix}_${device}.txt"
touch "$entity_file"


## Update an entity state
## -s|--state: entity value
##      e.g. '8'.
## -d|--delete: true to delete an entity
## -e|--entity: entity name as string
##      e.g. 'CPU usage'. Spaces will be replaced with underscores
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
            -a|--attributes) attributes="$2" ## Store the first name argument
                shift;;
            -i|--integration) integration="$2" ## Store the first name argument
                shift;;
            *) echo "Unknown parameter passed: $1" ## Display error for unknown parameter
        esac
        shift ## Move to the next argument
    done

    if [ "$delete" = true ]; then
        topic="homeassistant/${integration}/${entity// /_}/config"
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "$topic" -m ""
        sed -i "\;$topic;d" "${entity_file}"
        return 0
    fi

    if ! grep -Fqx "homeassistant/${integration}/${entity// /_}/config" "$entity_file"; then
        ## string found
#    else
        ## string not found, entity wasn't registered yet
        ## announce entity
#        echo "homeassistant/${integration}/${entity// /_}/config"
#        echo "{\"name\": \"$entity\", \"state_topic\": \"homeassistant/${integration}/${entity// /_}/state\", \"unique_id\": \"${prefix}_${device}_${entity// /_}\", $options \"device\": {\"identifiers\": [\"$prefix $device\"], \"name\": \"$device\", \"configuration_url\": \"$cfg_url\", \"sw_version\": \"$version\"}}"
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "homeassistant/${integration}/${entity// /_}/config" -m "{\"name\": \"$entity\", \"state_topic\": \"homeassistant/${integration}/${entity// /_}/state\", \"json_attributes_topic\": \"homeassistant/${integration}/${entity// /_}/attributes\", $options \"unique_id\": \"${prefix}_${device}_${entity// /_}\", \"device\": {\"identifiers\": [\"$prefix $device\"], \"name\": \"$device\", \"configuration_url\": \"$cfg_url\", \"sw_version\": \"$version\"}}"

        ## remember that this entity was already registered
        echo "homeassistant/${integration}/${entity// /_}/config" >> "$entity_file"
        echo "created $entity"
        sleep 1 ## otherwise the first value will be missed
    fi

    if [ -n "$state" ]; then
        ## send entity state via MQTT
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "homeassistant/${integration}/${entity// /_}/state" -m "$state"

        ## send entity data via REST, UNTESTED!!!
#        curl -X POST -H "Authorization: Bearer $iftoken" -H "Content-Type: application/json" -d "{\"state\":\"$state\"}" "http://${ifserver}:${ifport}/api/states/${integration}.${device}_${entity// /_}"
    fi

    if [ -n "$attributes" ]; then
        ## send entity attributes via MQTT
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "homeassistant/${integration}/${entity// /_}/attributes" -m "$attributes"
    fi
}

## optional='
## "icon": "mdi:numeric", 
## "state_class": "measurement", 
## "device_class": "temperature", 
## "unit_of_meas": "°C", 
## "entity_category": "diagnostic", 
## '
