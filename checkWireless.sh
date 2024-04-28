#!/bin/sh

. "${SCRIPTPATH}variables.sh"

eth1Temp=$(($(wl -i eth1 phy_tempsense|awk '{print $1}')/2+20))
eth2Temp=$(($(wl -i eth2 phy_tempsense|awk '{print $1}')/2+20))

mqtt_publish -e "WiFi 2G4 temperature" -s "$eth1Temp" -o '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C",'
mqtt_publish -e "WiFi 5G temperature" -s "$eth2Temp" -o '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C",'
