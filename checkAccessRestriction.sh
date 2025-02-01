#!/bin/sh

# On first execution it creates switch integrations to enable and disable the routers
# access restriction rules from within Home Assistant.
# On subsequent execution it checks the state of the switches and enables or disables
# each rule accordingly.

. './common.sh'

changed=false
group='access'
integration='switch'


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
    [ "$name" = 'rrule0' ] && continue

    ## delete topic if rule empty (no | in string)
    if ! echo "$rrule" | grep -q "|" 2>/dev/null; then
        echo "Deleting empty rule $name"
        mqtt_publish -g "$group" -n "$name" -i "$integration" -d true
        nvram unset "$name"
        continue
    fi

    ## get the desired friendly name and state from json
    meta=$(jq -r "select(.uid | endswith(\"_access_${name}\"))" "$entity_file")
    friendly=$(echo "$meta" | jq -r '.rule_name')
    state=$(echo "$meta" | jq -r '.state')

#    echo "$meta"
#    echo "'$desc' '$friendly' $state"

    ## delete topic if friendly name exists and has changed
    if [[ -n "$friendly" && "$friendly" != "$desc" ]]; then
        echo "Renaming rule '$friendly' to '$desc'"
        mqtt_publish -g "$group" -n "$name" -i "$integration" -d true
        fetch_entities ## update entity list
    fi

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
#    echo "$enable_old $enable_new"

    ## publish entity
    mqtt_publish -g "$group" -n "$name" -f "$desc" -i "$integration" -s "$enable_new" -a "\"rule_name\":\"$desc\"" -o "\"cmd_t\":\"${prefix}/${model}_${hw_addr}/${group}/${name}\",\"pl_off\":\"0\",\"pl_on\":\"1\",\"ic\":\"mdi:network-off-outline\","

    ## skip following steps if nothing has changed
    if [ "$enable_old" = "$enable_new" ]; then
        echo "$name state unchanged"
        continue
    fi

    ## set the first field to the value in variable $enable_new
    rrule=$(echo "$rrule" | sed "s/=.|/=$enable_new|/")

    ## replace the old rule with the new one
    nvram set "$rrule"

    ## notify and remember that something has changed
    echo "$name state changed: $enable_old => $enable_new"
    changed=true
done <<EOF
$rrules
EOF

## leave if nothing has changed
if [ "$changed" = false ]; then
    echo 'Nothing to do'
    return 0
fi
echo 'Updating access restrictions'

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
while [ "$(nvram get action_service)" = 'restrict-restart' ]; do
    echo -n
done
