#!/bin/sh

# Checks the number of connected clients.

. "./common.sh"

clients=$(arp -an | grep -cv vlan2)

mqtt_publish -e "clients count" -s "$clients" -o '"icon": "mdi:numeric", "state_class": "measurement", "entity_category": "diagnostic",'
