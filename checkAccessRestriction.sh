#!/bin/sh

. variables.sh

changed=false

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

    ## delete rrule if it's empty (no | in string)
    if [[ "$rrule" != *"|"* ]]; then
        echo "deleting $name"
        mqtt_publish -e "$name" -i "switch" -d true
        nvram unset "$name"
        continue
    fi

    if ! grep -q "$name" "${entity_file}"; then
        ## create topic and continue with next rule
        mqtt_publish -e "$name" -i "switch" -s "$enable_old" -a "{\"Rule description\": \"$desc\"}" -o "\"command_topic\": \"homeassistant/${integration}/${name// /_}/state\", \"payload_off\": \"0\", \"payload_on\": \"1\", \"icon\": \"mdi:eye\","
        continue
    fi

    ## update MQTT attributes with current rule name
    mqtt_publish -e "$name" -i "switch" -a "{\"Rule description\": \"$desc\"}"

    ## get the desired state
    enable_new=$(rest_get -e "$name" -i "switch")

    ## convert on and off into 1 and 0
    case $enable_new in
        "on") enable_new="1" ;;
        "off") enable_new="0" ;;
    esac
#    echo "$enable_old $enable_new"

    ## skip following steps if nothing has changed
    [[ "$enable_old" = "$enable_new" ]] && continue

    ## set the first field to the value in variable $enable_new
    rrule=$(echo "$rrule" | sed "s/=.|/=$enable_new|/")

    ## replace the old rule with the new one
    nvram set "$rrule"

    ## remember that something has changed
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