#!/bin/sh

# Checks the number of connected clients.

. './common.sh'

clients=$(arp -an | grep -cv vlan2)

mqtt_publish -g 'clients' -n 'count' -s "$clients" -o '"ic":"mdi:numeric","stat_cla":"measurement","ent_cat":"diagnostic"'
