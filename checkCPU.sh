#!/bin/sh

source variables.sh

cpuTemp=`cat /proc/dmu/temperature  | grep -o '[0-9]\+'`

mqtt_publish "CPU temperature" $cpuTemp '"icon": "mdi:thermometer", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "temperature", "unit_of_meas": "°C", '

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

#echo $cpu
total_old=$(( user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice ))
idle_old=$idle
sleep 4

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

#echo $cpu
total=$(( user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice ))

diff_total=$(( total - total_old ))
diff_idle=$(( idle - idle_old ))

# formula by Paul Colby (http://colby.id.au), no rights reserved ;)
usage=$((((1000*($diff_total-$diff_idle))/$diff_total+5)/10))
#echo $usage $diff_total $diff_idle

mqtt_publish "CPU usage" $usage '"icon": "mdi:percent", "state_class": "measurement", "entity_category": "diagnostic", "unit_of_meas": "%", '

#mqtt_publish "CPU IRQ" $irq '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU user" $user '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU nice" $nice '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU idle" $idle '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU guest" $guest '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU steal" $steal '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU iowait" $iowait '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU system" $system '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU softirq" $softirq '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
#mqtt_publish "CPU guest nice" $guest_nice '"icon": "mdi:timer-outline", "state_class": "measurement", "entity_category": "diagnostic", '
