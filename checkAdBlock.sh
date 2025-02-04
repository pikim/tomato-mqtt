#!/bin/sh

# On first execution it creates a switch integration to enable and disable the routers
# AdBlock service from within Home Assistant.
# On subsequent execution it checks the state of the switch and enables or disables the
# service accordingly.

. './common.sh'

group='AdBlock'
integration='switch'


## get current AdBlock state
if adblock status | grep -q "State = Loaded"; then
    enable_old='1'
else
    enable_old='0'
fi

## get the desired state
state=$(jq -r "select(.uid | endswith(\"${group}_state\")) | .state" "$entity_file")

enable_new=null
## convert state
case $state in
    '1') enable_new='1' ;;
    '0') enable_new='0' ;;
    'on') enable_new='1' ;;
    'off') enable_new='0' ;;
    *) echo "Unknown parameter passed: \"$state\". Using current state: \"$enable_old\"."
        enable_new="$enable_old" ;;
esac
#echo "AdBlock states: router=${enable_old}; hass=${enable_new}"

## publish switch entity
mqtt_publish -g "$group" -n 'state' -f "$group" -i "$integration" -s "$enable_new" -u true -o "\"cmd_t\":\"${prefix}/${model}_${hw_addr}/${group}/state\",\"pl_off\":\"0\",\"pl_on\":\"1\",\"ic\":\"mdi:advertisements-off\""

error=false
## leave if nothing has changed
if [ "$enable_old" = "$enable_new" ]; then
    echo 'AdBlock state unchanged'
else
    echo "AdBlock state changed: $enable_old => $enable_new"

    if [ "$enable_new" = 1 ]; then
        echo 'Starting AdBlock'
        output=$(adblock start)
        echo "$output"

        if echo "$output" | grep -q 'Adblock/DNS-filtering is disabled! Exiting...'; then
            error=true
        fi
    else
        echo 'Stopping AdBlock'
        adblock stop
    fi
fi

## publish error state
mqtt_publish -g "$group" -n 'error' -s "$error" -o '"ic":"mdi:exclamation-thick","ent_cat":"diagnostic"'
