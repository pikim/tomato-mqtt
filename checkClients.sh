#!/bin/sh

source variables.sh

clients=`arp -an | grep -v vlan2 | wc -l`

mqtt_publish -e "clients count" -s $clients -d '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic", '
