#!/bin/sh

# Holds the base functionality and variables for all the other scripts.

## read custom configuration
. './config.sh'

## define variables
prefix='FreshTomato'
discovery_topic='homeassistant'

manu_model=$(nvram get t_model_name)
manu=$(echo "$manu_model" | awk '{print $1}')
model=$(echo "$manu_model" | awk '{print $2}')

version=$(nvram get os_version)
ip_addr=$(nvram get lan_ipaddr)
hostname=$(nvram get lan_hostname)
hw_addr=$(echo "$(nvram get lan_hwaddr)" | tr -d ':')

## set https or http as protocol
[ "$(nvram get https_enable)" = "1" ] && cfg_url="https://$ip_addr"
[ "$(nvram get http_enable)" = "1" ] && cfg_url="http://$ip_addr"

## file settings
file_prefix="/tmp/${prefix}_${model}"
entity_file="${file_prefix}.entity"
json_file="${file_prefix}.json"
twig_file="${file_prefix}.twig"
pid_file="${file_prefix}.pid"


## source everything except the variables only once
[ -n "${sourced_variables_sh+x}" ] && return
sourced_variables_sh=true


## Fetch device entities from Home Assistant
fetch_entities(){
    echo 'Fetching device entities from Home Assistant'
    ## locking taken from https://gist.github.com/didenko/a92beec14ce2ca1c98f3
    exec 221>"${pid_file}"
    flock --exclusive 221
    echo ${$}>&221

    ## update device_name in template.twig
    if [ ! -e "$twig_file" ]; then
        sed "s/{% set device_name =.*/{% set device_name = '$hostname' %}/g" "template.twig" > "$twig_file"
    fi

    ## request entities
    curl -X POST "http://${ra_addr}:${ra_port}/api/template" \
        -H "Authorization: Bearer $ra_token" \
        -H "Content-Type: application/json" \
        -d @"$twig_file" \
        > "$json_file"

    ## replace single with double quotes (and format file)
    sed -i "s/'/\"/g" "$json_file"
#    content=$(jq '.' "$json_file") && echo "$content" > "$json_file"

    ## extract the entity data from json file
    jq '.[][].entities[]' "$json_file" > "$entity_file"

    ## critical part finished, unlock
    flock --unlock 221
}

## execute function
fetch_entities


## Publish device discovery, state and/or attributes
## -n|--name: entity name as string
##      e.g. 'CPU usage'. Spaces will be replaced with underscores
## -g|--group: group of the entity
##      e.g. 'CPU'
## -s|--state: entity value
##      e.g. '8'.
## -o|--options: additional information for MQTT discovery, as comma terminated string (optional)
##      e.g. '"icon":"mdi:numeric","state_class":"measurement","device_class":"temperature","unit_of_meas":"°C","entity_category":"diagnostic"'
## -f|--friendly: friendly name as string (optional)
##      e.g. 'CPU usage'
## -a|--attributes: attributes for the entity (optional)
##      e.g. '"rule_name": "Block Server"'
## -i|--integration: integration type (optional, default is 'sensor')
##      e.g. "binary_sensor", "sensor" or "switch"
## -c|--config_topic: custom MQTT configuration topic (optional)
##      e.g. 'homeassistant/sensor/FreshTomato_R7000_AABBCCDDEEFF/clients_count/config'.
## -d|--delete: true to delete an entity
## -u|--unique: true to add unique_id
mqtt_publish(){
    _name=''
    _group=''
    _state=''
    _options=''
    _friendly=''
    _attributes=''
    _integration='sensor'
    _config_topic=''
    _delete=false
    _unique=false

    ## Loop through the provided arguments
    ## taken from https://linuxsimply.com/bash-scripting-tutorial/parameters/named-parameters/
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n|--name) _name="$2" ## Store the first name argument
                shift;;
            -g|--group) _group="$2" ## Store the first name argument
                shift;;
            -s|--state) _state="$2" ## Store the first name argument
                shift;;
            -o|--options) _options="$2" ## Store the first name argument
                shift;;
            -f|--friendly) _friendly="$2" ## Store the first name argument
                shift;;
            -a|--attributes) _attributes="$2" ## Store the first name argument
                shift;;
            -i|--integration) _integration="$2" ## Store the first name argument
                shift;;
            -c|--config_topic) _config_topic="$2" ## Store the first name argument
                shift;;
            -d|--delete) _delete="$2" ## Store the first name argument
                shift;;
            -u|--unique) _unique="$2" ## Store the first name argument
                shift;;
            *) echo "Unknown parameter passed: $1" ## Display error for unknown parameter
        esac
        shift ## Move to the next argument
    done

    ## clean name and store it as entity
    _entity=$(echo "$_name" | sed 's/[^A-Za-z0-9\._]/_/g' | sed 's/[_]\{2,\}/_/g')

    ## define topics once and reuse them
    _cfg_topic="${discovery_topic}/${_integration}/${prefix}_${model}_${hw_addr}/${_group}_${_entity}/config"
    _attr_topic="${prefix}/${model}_${hw_addr}/${_group}/${_entity}/attr"
    _state_topic="${prefix}/${model}_${hw_addr}/${_group}/${_entity}"

    if [ -n "$_config_topic" ]; then
        _cfg_topic="$_config_topic"
    fi

    if [ "$_delete" = true ]; then
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "$_cfg_topic" -m ''
        return
    fi

    if [ "$_friendly" = '' ]; then
        ## no friendly name given, create one
        _friendly="${_group} ${_name}"
    fi

    if [ -n "$_options" ]; then
        ## make sure the string ends with a comma
        _options="${_options%,},"
    fi

    ## create variables and clean names
    _object_id="${hostname}_${_group}_${_entity}"
    _object_id=$(echo "$_object_id" | sed 's/[^A-Za-z0-9\_]/_/g' | sed 's/[_]\{2,\}/_/g')

    _unique_str=''
    if [ -n "$_unique" ]; then
        _unique_id="${hw_addr}_${_group}_${_entity}"
        _unique_id=$(echo "$_unique_id" | sed 's/[^A-Za-z0-9\_]/_/g' | sed 's/[_]\{2,\}/_/g')
        _unique_str="\"uniq_id\":\"${_unique_id}\","
    fi

    if ! grep -Fiq "$_unique_id" "$entity_file"; then
        ## prepare data to be sent
        _json_data=\
"{\
\"name\":\"${_friendly}\",\
\"def_ent_id\":\"${_integration}.${_object_id}\",\
\"obj_id\":\"${_object_id}\",\
${_unique_str}\
\"stat_t\":\"${_state_topic}\",\
\"json_attr_t\":\"${_attr_topic}\",\
${_options}\
\"dev\":\
{\
\"name\":\"${hostname}\",\
\"ids\":[\"${manu_model} ${hw_addr}\"],\
\"mf\":\"${manu}\",\
\"mdl\":\"${model}\",\
\"cu\":\"${cfg_url}\",\
\"sn\":\"${hw_addr}\",\
\"sw\":\"${version}\"\
}\
}"

        ## string not found in file, entity wasn't registered yet
        ## announce entity
#        echo "$_cfg_topic => $_json_data"
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "$_cfg_topic" -m "$_json_data"

        ## after the discovery topic it takes some time until attr and state will show up
        usleep 400000
    fi

    if [ -n "$_state" ]; then
        ## send entity state via MQTT
#        echo "$_state_topic => $_state"
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "$_state_topic" -m "$_state"

        ## send entity data via REST, UNTESTED!!!
#        curl -X POST -H "Authorization: Bearer $ra_token" -H "Content-Type: application/json" -d "{\"state\":\"$state\"}" "http://${ra_addr}:${ra_port}/api/states/${integration}.${model}_${entity}"
    fi

    if [ -n "$_attributes" ]; then
        ## remove trailing comma
        _attributes="${_attributes%,}"

        if [ "$_unique" = true ]; then
            _attributes="${_attributes},\"uid\":\"$_unique_id\""
        fi
    else
        if [ "$_unique" = true ]; then
            _attributes="\"uid\":\"$_unique_id\""
        fi
    fi

    if [ -n "$_attributes" ]; then
        ## send entity attributes via MQTT
#        echo "$_attr_topic => $_attributes"
        mosquitto_pub -h "$addr" -p "$port" -u "$username" -P "$password" -t "$_attr_topic" -m "{$_attributes}"
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
    _entity=''
    _property=''
    _integration='sensor'

    ## Loop through the provided arguments
    ## taken from https://linuxsimply.com/bash-scripting-tutorial/parameters/named-parameters/
    while [ "$#" -gt 0 ]; do
        case $1 in
            -e|--entity) _entity="$2" ## Store the first name argument
                shift;;
            -p|--property) _property="$2" ## Store the first name argument
                shift;;
            -i|--integration) _integration="$2" ## Store the first name argument
                shift;;
            *) echo "Unknown parameter passed: $1" ## Display error for unknown parameter
        esac
        shift ## Move to the next argument
    done

    _entity="${_entity// /_}"

#    echo "Authorization: Bearer $ra_token"
#    echo "http://${ra_addr}:${ra_port}/api/states/${_integration}.${model}_${_entity}"
    curl -X GET -s -H "Authorization: Bearer $ra_token" -H "Content-Type: application/json" "http://${ra_addr}:${ra_port}/api/states/${_integration}.${model}_${_entity}" | jq -r ".${_property}"
}

## curl get response:
## {"entity_id":"sensor.r6400v2_clients_count","state":"12","attributes":{},"last_changed":"2024-04-22T21:17:06.724753+00:00","last_updated":"2024-04-22T21:17:06.724753+00:00","context":{"id":"01HW3TPVS4RYPXA3XVK0CG36B8","parent_id":null,"user_id":"0a5940fde5564d5b9e4baf64acdd78a7"}}


## execute when script was directly called
if [ "${BASH_SOURCE[0]}" = "$0" ] || [ "$(basename "$0")" = "common.sh" ]; then
    fetch_entities "$@"
fi
