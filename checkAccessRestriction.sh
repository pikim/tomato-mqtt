#!/bin/sh

# On first execution it creates switch integrations to enable and disable the routers
# access restriction rules from within Home Assistant.
# On subsequent execution it checks the state of the switches and enables or disables
# each rule accordingly.

. "./common.sh"

changed=false
integration="switch"


## get all the rules
rrules=$(nvram show 2> /dev/null | grep -E "rrule[0-9]+")
#echo $rrules


## iterate over the rules
while IFS= read -r rrule; do
#    echo "$rrule"
#    continue

    ## get rule name and description
    name=$(echo "$rrule" | awk -F"=" '{print $1}')
    desc=$(echo "$rrule" | awk -F"|" '{print $NF}')
    enable_old=$(echo "$rrule" | awk -F"[=|]" '{print $2}')
#    echo "$name  $desc  $enable_old"

    ## skip dummy rrule0
    [ "$name" = "rrule0" ] && continue

    ## get the desired friendly name and state from json
    meta=$(jq ". | select(.friendly_name == \"$desc\")" "$entity_file")
    friendly=$(echo "$meta" | jq -r '.friendly_name')
    state=$(echo "$meta" | jq -r '.state')

    ## delete rrule if it's empty (no | in string)
    if ! echo "$rrule" | grep -q "|" 2>/dev/null; then
        echo "Deleting empty rule $name"
        mqtt_publish -e "$name" -i "$integration" -d true
        nvram unset "$name"
        continue
    fi

#    echo "'$desc' '$friendly'"
#    echo "$meta"

    ## delete topic if friendly name has changed
    if [ "$desc" != "$friendly" ]; then
        echo "Renaming rule '$friendly' to '$desc'"
        mqtt_publish -e "$name" -i "$integration" -d true
        friendly="$desc"
    fi
#    echo "$name \"$friendly\""

    ## create topic if it doesn't exist and skip the following steps
    if [ "$meta" = "" ]; then
        echo "Creating entity $name"
        mqtt_publish -e "$name" -f "$friendly" -i "$integration" -s "$enable_old" -o "\"command_topic\": \"homeassistant/${integration}/${name// /_}/state\", \"payload_off\": \"0\", \"payload_on\": \"1\", \"icon\": \"mdi:network-off-outline\","
        continue
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
#    echo "$enable_old $enable_new"

    ## skip following steps if nothing has changed
    if [ "$enable_old" = "$enable_new" ]; then
        echo "State of $name didn't change"
        continue
    fi

    ## set the first field to the value in variable $enable_new
    rrule=$(echo "$rrule" | sed "s/=.|/=$enable_new|/")

    ## replace the old rule with the new one
    nvram set "$rrule"

    ## notify and remember that something has changed
    echo "State of $name has changed"
    changed=true
done <<EOF
$rrules
EOF

## leave if nothing has changed
if [ "$changed" = false ]; then
    echo "Nothing has changed"
    return 0
fi
echo "Updating access restrictions"

## wait if any service is currently being restarted
nvstat=$(nvram get action_service)
while [ "$nvstat" != "" ]; do
    echo -n
done

## prepare to restart the service by killing the init process
nvram set action_service=restrict-restart

## kill the init process
kill -USR1 1

## wait for the service to restart
while [ "$(nvram get action_service)" = "restrict-restart" ]; do
    echo -n
done
