## any additional mount points to monitor here, space delimited like "/jffs /nfs"
disks="/tmp/mnt/SiteCom_32MB"

## MQTT connection settings
addr="hassos.home."
port="1883"
username="ha_mqtt_user"
password="DsyznlgMkqxSQ7jc"

## MQTT topic settings
prefix="FreshTomato"
device=`nvram get t_fix1`
version=`nvram get os_version`
ip_addr=`nvram get lan_ipaddr`

[ `nvram get https_enable` -eq "1" ] && cfg_url="https://$ip_addr"
[ `nvram get http_enable` -eq "1" ] && cfg_url="http://$ip_addr"


## Update a sensor state
## arg1: sensor name as string
##       e.g. 'CPU load'. Spaces will bei replaced with underscores
## arg2: sensor name as string
##       e.g. 'CPU load'. Spaces will bei replaced with underscores
## arg3: additional (but optional) information as comma terminated string
##       e.g. '"icon": "mdi:numeric", "state_class": "measurement", "device_class": "temperature", "unit_of_meas": "°C", "entity_category": "diagnostic", '
mqtt_publish(){
    sensor=$1
    value=$2
    optional=$3

    if ! grep -Fqx "homeassistant/sensor/${sensor// /_}/config" "${prefix}_${device}.txt"
    then
        ## string found
#    else
        ## string not found, sensor wasn't registered yet
        ## announce sensor
        mosquitto_pub -h $addr -p $port -u $username -P $password -t "homeassistant/sensor/${sensor// /_}/config" -m "{\"name\": \"$sensor\", \"state_topic\": \"homeassistant/sensor/${sensor// /_}/state\", \"unique_id\": \"${prefix}_${device}_${sensor// /_}\", $optional \"device\": {\"identifiers\": [\"$prefix $device\"], \"name\": \"$device\", \"configuration_url\": \"$cfg_url\", \"sw_version\": \"$version\"}}"

        ## remember that this sensor was already registered
        echo "homeassistant/sensor/${sensor// /_}/config" >> "${prefix}_${device}.txt"
        sleep 1 ## otherwise the first value will miss
    fi

    ## send sensor data
    mosquitto_pub -h $addr -p $port -u $username -P $password -t "homeassistant/sensor/${sensor// /_}/state" -m "$value"
}

## optional='
## "icon": "mdi:numeric", 
## "state_class": "measurement", 
## "device_class": "temperature", 
## "unit_of_meas": "°C", 
## "entity_category": "diagnostic", 
## '
