#!/bin/sh

# Checks the WiFi temperature(s) and noise level(s).

. './common.sh'

# eth1 = 2G4, eth2 = 5G
for iface in "eth1:2G4" "eth2:5G"; do
    dev="${iface%%:*}"
    name="${iface#*:}"

    rawTemp=$(wl -i "$dev" phy_tempsense 2>/dev/null)

    if [ -n "$rawTemp" ]; then
        set -- $rawTemp
        val=$1

        temp=$(( (val / 2) + 20 ))
        noise=$(wl -i "$dev" noise)

        mqtt_publish -g 'WiFi' -n "$name temperature" -s "$temp" -o '"ic":"mdi:thermometer","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"temperature","unit_of_meas":"°C"'
        mqtt_publish -g 'WiFi' -n "$name noise" -s "$noise" -o '"ic":"mdi:wifi-alert","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"signal_strength","unit_of_meas":"dB"'
    fi
done
