#!/bin/sh

# Checks the WiFi temperature(s) and noise level(s).

. "./common.sh"

eth1Temp=$(($(wl -i eth1 phy_tempsense|awk '{print $1}')/2+20))
eth2Temp=$(($(wl -i eth2 phy_tempsense|awk '{print $1}')/2+20))
eth1Noise=$(wl -i eth1 noise)
eth2Noise=$(wl -i eth2 noise)

mqtt_publish -e "WiFi 2G4 temperature" -s "$eth1Temp" -o '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C",'
mqtt_publish -e "WiFi 5G temperature" -s "$eth2Temp" -o '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C",'
mqtt_publish -e "WiFi 2G4 noise" -s "$eth1Noise" -o '"icon": "mdi:wifi-alert", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "signal_strength", "unit_of_meas": "dB",'
mqtt_publish -e "WiFi 5G noise" -s "$eth2Noise" -o '"icon": "mdi:wifi-alert", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "signal_strength", "unit_of_meas": "dB",'
