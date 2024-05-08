#!/bin/sh

. "${SCRIPTPATH}variables.sh"

changed=false

## define and create a file for the friendly names
friendly_file="${folder}${prefix}_${device}_friendly.txt"
touch "$friendly_file"

## get all the rules
rrules=$(nvram show 2> /dev/null | grep -E "rrule[0-9]+")
#echo $rrules

while IFS= read -r rrule; do
#    echo "$rrule"
#    continue

    ## get rule name and description
    name=$(echo "$rrule" | awk -F"=" '{print $1}')
    desc=$(echo "$rrule" | awk -F"|" '{print $NF}')
    enable_old=$(echo "$rrule" | awk -F"[=|]" '{print $2}')
    integration="switch"
#    echo "$name  $desc  $enable_old"

    ## skip dummy rrule
    [[ "$name" = "rrule0" ]] && continue

    ## delete rrule if it's empty (no | in string)
    if [[ "$rrule" != *"|"* ]]; then
        echo "deleting $name"
        mqtt_publish -e "$name" -i "$integration" -d true
        sed -i "/$name /d" "$friendly_file"
        nvram unset "$name"
        continue
    fi

    friendly_line=$(grep -F "$name \"" "$friendly_file")
    if [ "$friendly_line" = "" ]; then
        ## friendly name not stored, store it now
        friendly="$desc"
        echo "$name \"$friendly\"" >> "$friendly_file"
    else
        ## friendly name was already stored, get it
        friendly=$(echo "$friendly_line" | awk -F'"' '{ print $2 }')

        ## delete topic if friendly name has changed
        if [ "$desc" != "$friendly" ]; then
            mqtt_publish -e "$name" -i "$integration" -d true
            echo "rename $friendly to $desc"
            friendly="$desc"
            sed -i "s%$friendly_line%$name \"$friendly\"%g" "$friendly_file"
        fi
    fi
#    echo "$name \"$friendly\""

    ## check if topic was already created before
    if ! grep -q "$name" "${entity_file}"; then
        ## create topic and continue with next rule
        mqtt_publish -e "$name" -f "$friendly" -i "$integration" -s "$enable_old" -a "{\"Rule description\": \"$desc\"}" -o "\"command_topic\": \"homeassistant/${integration}/${name// /_}/state\", \"payload_off\": \"0\", \"payload_on\": \"1\", \"icon\": \"mdi:network-off-outline\","
        continue
    fi

    ## update MQTT attributes with current rule name
    mqtt_publish -e "$name" -i "$integration" -a "{\"Rule description\": \"$desc\"}"

    ## get the desired state
    enable_new=$(rest_get -e "$name" -i "$integration")

    ## convert on and off into 1 and 0
    case $enable_new in
        "on") enable_new="1" ;;
        "off") enable_new="0" ;;
        *) echo "Unknown parameter passed: \"$enable_new\". Setting it to \"1\" instead."
            enable_new="1" ;;
    esac
#    echo "$enable_old $enable_new"

    ## skip following steps if nothing has changed
    [[ "$enable_old" = "$enable_new" ]] && continue

    ## set the first field to the value in variable $enable_new
    rrule=$(echo "$rrule" | sed "s/=.|/=$enable_new|/")

    ## replace the old rule with the new one
    nvram set "$rrule"

    ## notify and remember that something has changed
    echo "$name has changed"
    changed=true
done <<EOF
$rrules
EOF

## leave if nothing has changed
[[ "$changed" = false ]] && echo "nothing changed" && return 0
echo "updating access restrictions"

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
