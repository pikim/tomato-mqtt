#!/bin/sh

source variables.sh

clients=`arp -an | grep -v vlan2 | wc -l`

mqtt_publish "clients count" $clients '"icon": "mdi:numeric", "state_class": "measurement", '
