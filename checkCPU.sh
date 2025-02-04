#!/bin/sh

# Checks the CPU temperature and CPU usage in percent. Should not be executed in parallel
# with the other script as its result will be distorted otherwise.

. './common.sh'

cpuTemp=$(grep -o '[0-9]\+' /proc/dmu/temperature)

mqtt_publish -g 'CPU' -n 'temperature' -s "$cpuTemp" -o '"ic":"mdi:thermometer","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"temperature","unit_of_meas":"°C"'

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

mqtt_publish -g 'CPU' -n 'usage' -s "$usage" -o '"ic":"mdi:percent","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'

#mqtt_publish -g 'CPU'' -n 'IRQ' -s $irq -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'user' -s $user -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'nice' -s $nice -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'idle' -s $idle -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'guest' -s $guest -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'steal' -s $steal -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'iowait' -s $iowait -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'system' -s $system -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'softirq' -s $softirq -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
#mqtt_publish -g 'CPU'' -n 'guest nice' -s $guest_nice -o '"ic":"mdi:timer-outline","stat_cla":"measurement","ent_cat":"diagnostic"'
