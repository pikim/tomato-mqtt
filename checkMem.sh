#!/bin/sh

# Checks some memory informations of RAM and NVRAM.

. './common.sh'

mem=$(cat /proc/meminfo)
total=$(echo "$mem" | grep ^MemTotal | awk '{print $2}')
free=$(echo "$mem" | grep ^MemFree | awk '{print $2}')
used=$(( total - free ))
#buffers=$(echo "$mem" | grep ^Buffers | awk '{print $2}')
#cached=$(echo "$mem" | grep ^Cached: | awk '{print $2}')
#active=$(echo "$mem" | grep ^Active: | awk '{print $2}')
#inactive=$(echo "$mem" | grep ^Inactive: | awk '{print $2}')

mqtt_publish -g 'RAM' -n 'free' -s "$free" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
mqtt_publish -g 'RAM' -n 'used' -s "$used" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
mqtt_publish -g 'RAM' -n 'total' -s "$total" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
#mqtt_publish -g 'RAM' -n 'active' -s "$active" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
#mqtt_publish -g 'RAM' -n 'cached' -s "$cached" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
#mqtt_publish -g 'RAM' -n 'buffers' -s "$buffers" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'
#mqtt_publish -g 'RAM' -n 'inactive' -s "$inactive" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"kB"'

nvram=$(nvram show 2>&1 1>/dev/null | tr -cd ' 0-9')
nv_used=$(echo "$nvram" | awk '{print $1}')
nv_free=$(echo "$nvram" | awk '{print $2}')
nv_total=$(( nv_used + nv_free ))

mqtt_publish -g 'NVRAM' -n 'free' -s "$nv_free" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
mqtt_publish -g 'NVRAM' -n 'used' -s "$nv_used" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
mqtt_publish -g 'NVRAM' -n 'total' -s "$nv_total" -o '"ic":"mdi:memory","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
