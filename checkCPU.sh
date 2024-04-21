#!/bin/sh

source variables.sh

cpuTemp=`cat /proc/dmu/temperature  | grep -o '[0-9]\+'`

cpu=`cat /proc/stat | head -n1 | sed 's/cpu //'`
user=`echo $cpu | awk '{print $1}'`
nice=`echo $cpu | awk '{print $2}'`
system=`echo $cpu | awk '{print $3}'`
idle=`echo $cpu | awk '{print $4}'`
iowait=`echo $cpu | awk '{print $5}'`
irq=`echo $cpu | awk '{print $6}'`
softirq=`echo $cpu | awk '{print $7}'`
steal=`echo $cpu | awk '{print $8}'`
guest=`echo $cpu | awk '{print $9}'`
guest_nice=`echo $cpu | awk '{print $10}'`

mqtt_publish "CPU temperature" $cpuTemp '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C", '
mqtt_publish "CPU IRQ" $irq '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU user" $user '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU nice" $nice '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU idle" $idle '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU guest" $guest '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU steal" $steal '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU iowait" $iowait '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU system" $system '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU softirq" $softirq '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
mqtt_publish "CPU guest nice" $guest_nice '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
