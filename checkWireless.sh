#!/bin/sh

source ./variables.sh

eth1Temp=$((`wl -i eth1 phy_tempsense|awk {' print $1 '}`/2+20))
eth2Temp=$((`wl -i eth2 phy_tempsense|awk {' print $1 '}`/2+20))

mqtt_publish "WiFi 2G4 temperature" $eth1Temp '"icon": "mdi:thermometer", "state_class": "measurement", "device_class": "temperature", "unit_of_meas": "°C", "entity_category": "diagnostic", '
mqtt_publish "WiFi 5G temperature" $eth2Temp '"icon": "mdi:thermometer", "state_class": "measurement", "device_class": "temperature", "unit_of_meas": "°C", "entity_category": "diagnostic", '
