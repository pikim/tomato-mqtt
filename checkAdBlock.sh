#!/bin/sh

# On first execution it creates a switch integration to enable and disable the routers
# AdBlock service from within Home Assistant.
# On subsequent execution it checks the state of the switch and enables or disables the
# service accordingly.

. "${SCRIPTPATH}variables.sh"

name="AdBlock"
integration="switch"

if adblock status | grep -q "State = Loaded"; then
    enable_old="1"
else
    enable_old="0"
fi

if ! grep -q "$name" "${entity_file}"; then
    ## create topic
    mqtt_publish -e "$name" -i "$integration" -s "$enable_old" -o "\"command_topic\": \"homeassistant/${integration}/${name// /_}/state\", \"payload_off\": \"0\", \"payload_on\": \"1\", \"icon\": \"mdi:advertisements-off\","
fi

## get the desired state
enable_new=$(rest_get -e "$name" -i "$integration" -p "state")

## convert on and off
case $enable_new in
    "on") enable_new="1" ;;
    "off") enable_new="0" ;;
    *) echo "Unknown parameter passed: \"$enable_new\". Setting it to \"1\" instead."
        enable_new="1" ;;
esac
#echo "$enable_old $enable_new"

## leave if nothing has changed
[[ "$enable_old" = "$enable_new" ]] && echo "nothing changed" && return 0

if [ "$enable_new" = 1 ]; then
    echo "starting AdBlock"
    adblock start
else
    echo "stopping AdBlock"
    adblock stop
fi
