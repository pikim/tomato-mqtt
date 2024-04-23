## read custom configuration
source config.sh

## MQTT topic settings
prefix="FreshTomato"
device=`nvram get t_fix1`
version=`nvram get os_version`
ip_addr=`nvram get lan_ipaddr`

[ `nvram get https_enable` -eq "1" ] && cfg_url="https://$ip_addr"
[ `nvram get http_enable` -eq "1" ] && cfg_url="http://$ip_addr"


## Update an entity state
## arg1: entity name as string
##       e.g. 'CPU usage'. Spaces will be replaced with underscores
## arg2: entity value
##       e.g. '8'.
## arg3: additional (but optional) information for MQTT discovery, as comma terminated string
##       e.g. '"icon": "mdi:numeric", "state_class": "measurement", "device_class": "temperature", "unit_of_meas": "°C", "entity_category": "diagnostic", '
mqtt_publish(){
    entity=$1
    value=$2
    optional=$3

    if [ ! -f "${prefix}_${device}.txt" ]; then
        touch "${prefix}_${device}.txt"
        sync
    fi

    if ! grep -Fqx "homeassistant/sensor/${entity// /_}/config" "${prefix}_${device}.txt"
    then
        ## string found
#    else
        ## string not found, entity wasn't registered yet
        ## announce entity
        mosquitto_pub -h $addr -p $port -u $username -P $password -t "homeassistant/sensor/${entity// /_}/config" -m "{\"name\": \"$entity\", \"state_topic\": \"homeassistant/sensor/${entity// /_}/state\", \"unique_id\": \"${prefix}_${device}_${entity// /_}\", $optional \"device\": {\"identifiers\": [\"$prefix $device\"], \"name\": \"$device\", \"configuration_url\": \"$cfg_url\", \"sw_version\": \"$version\"}}"

        ## remember that this entity was already registered
        echo "homeassistant/sensor/${entity// /_}/config" >> "${prefix}_${device}.txt"
        sleep 1 ## otherwise the first value will be missed
    fi

    ## send entity data via MQTT
    mosquitto_pub -h $addr -p $port -u $username -P $password -t "homeassistant/sensor/${entity// /_}/state" -m "$value"

    ## send entity data via REST, UNTESTED!!!
#    curl -X POST -H "Authorization: Bearer $iftoken" -H "Content-Type: application/json" -d "{\"state\":\"$value\"}" "http://${ifserver}:${ifport}/api/states/sensor.${device}_${entity// /_}"
}
}

## optional='
## "icon": "mdi:numeric", 
## "state_class": "measurement", 
## "device_class": "temperature", 
## "unit_of_meas": "°C", 
## "entity_category": "diagnostic", 
## '
