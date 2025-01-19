#!/bin/sh

# Checks the WiFi temperature(s) and noise level(s).

. "./common.sh"

eth1Temp=$(wl -i eth1 phy_tempsense)
if [ -n "$eth1Temp" ]; then
    eth1Temp=$(($(echo "$eth1Temp" | awk '{print $1}')/2+20))
    eth1Noise=$(wl -i eth1 noise)

    mqtt_publish -g "WiFi" -n "2G4 temperature" -s "$eth1Temp" -o '"ic":"mdi:thermometer","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"temperature","unit_of_meas":"°C",'
    mqtt_publish -g "WiFi" -n "2G4 noise" -s "$eth1Noise" -o '"ic":"mdi:wifi-alert","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"signal_strength","unit_of_meas":"dB",'
fi

eth2Temp=$(wl -i eth2 phy_tempsense)
if [ -n "$eth2Temp" ]; then
    eth2Temp=$(($(echo "$eth2Temp" | awk '{print $1}')/2+20))
    eth2Noise=$(wl -i eth2 noise)

    mqtt_publish -g "WiFi" -n "5G temperature" -s "$eth2Temp" -o '"ic":"mdi:thermometer","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"temperature","unit_of_meas":"°C",'
    mqtt_publish -g "WiFi" -n "5G noise" -s "$eth2Noise" -o '"ic":"mdi:wifi-alert","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"signal_strength","unit_of_meas":"dB",'
fi
