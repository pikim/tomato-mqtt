#!/bin/sh

# On first execution it creates a switch integration to enable and disable the routers
# AdBlock service from within Home Assistant.
# On subsequent execution it checks the state of the switch and enables or disables the
# service accordingly.

. "./common.sh"

name="AdBlock"
integration="switch"


## get current AdBlock state
if adblock status | grep -q "State = Loaded"; then
    enable_old="1"
else
    enable_old="0"
fi

## get the desired state
meta=$(jq ". | select(.friendly_name == \"$name\")" "$entity_file")
state=$(echo "$meta" | jq -r '.state')

## create topic if it doesn't exist
if [ "$meta" = "" ]; then
    echo "Creating entity $name"
    mqtt_publish -e "$name" -i "$integration" -s "$enable_old" -o "\"command_topic\": \"homeassistant/${integration}/${name// /_}/state\", \"payload_off\": \"0\", \"payload_on\": \"1\", \"icon\": \"mdi:advertisements-off\","
fi

## convert state
case $state in
    "1") enable_new="1" ;;
    "0") enable_new="0" ;;
    "on") enable_new="1" ;;
    "off") enable_new="0" ;;
    *) echo "Unknown parameter passed: \"$state\". Setting it to \"1\" instead."
        enable_new="1" ;;
esac
echo "AdBlock states: router=${enable_old}; hass=${enable_new}"

## leave if nothing has changed
if [ "$enable_old" = "$enable_new" ]; then
    echo "AdBlock state didn't change"
    return 0
fi

if [ "$enable_new" = 1 ]; then
    echo "Starting AdBlock"
    adblock start
else
    echo "Stopping AdBlock"
    adblock stop
fi
