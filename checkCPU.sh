#!/bin/sh

# Checks the CPU temperature and CPU usage in percent. Should not be executed in parallel
# with the other script as its result will be distorted otherwise.

. "./common.sh"

cpuTemp=$(grep -o '[0-9]\+' /proc/dmu/temperature)

mqtt_publish -e "CPU temperature" -s "$cpuTemp" -o '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C",'

cpu=$(head -n1 /proc/stat | sed 's/cpu //')
user=$(echo "$cpu" | awk '{print $1}')
nice=$(echo "$cpu" | awk '{print $2}')
system=$(echo "$cpu" | awk '{print $3}')
idle=$(echo "$cpu" | awk '{print $4}')
iowait=$(echo "$cpu" | awk '{print $5}')
irq=$(echo "$cpu" | awk '{print $6}')
softirq=$(echo "$cpu" | awk '{print $7}')
steal=$(echo "$cpu" | awk '{print $8}')
guest=$(echo "$cpu" | awk '{print $9}')
guest_nice=$(echo "$cpu" | awk '{print $10}')

#echo $cpu
total_old=$(( user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice ))
idle_old=$idle
sleep 4

cpu=$(head -n1 /proc/stat | sed 's/cpu //')
user=$(echo "$cpu" | awk '{print $1}')
nice=$(echo "$cpu" | awk '{print $2}')
system=$(echo "$cpu" | awk '{print $3}')
idle=$(echo "$cpu" | awk '{print $4}')
iowait=$(echo "$cpu" | awk '{print $5}')
irq=$(echo "$cpu" | awk '{print $6}')
softirq=$(echo "$cpu" | awk '{print $7}')
steal=$(echo "$cpu" | awk '{print $8}')
guest=$(echo "$cpu" | awk '{print $9}')
guest_nice=$(echo "$cpu" | awk '{print $10}')

#echo $cpu
total=$(( user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice ))

diff_total=$(( total - total_old ))
diff_idle=$(( idle - idle_old ))

# formula by Paul Colby (http://colby.id.au), no rights reserved ;)
usage=$((((1000*(diff_total-diff_idle))/diff_total+5)/10))
#echo $usage $diff_total $diff_idle

mqtt_publish -e "CPU usage" -s "$usage" -o '"icon": "mdi:percent", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "%",'

#mqtt_publish -e "CPU IRQ" -s $irq -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU user" -s $user -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU nice" -s $nice -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU idle" -s $idle -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU guest" -s $guest -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU steal" -s $steal -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU iowait" -s $iowait -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU system" -s $system -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU softirq" -s $softirq -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
#mqtt_publish -e "CPU guest nice" -s $guest_nice -o '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic",'
