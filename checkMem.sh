#!/bin/sh

source variables.sh

mem=`cat /proc/meminfo`
total=`echo "$mem" | grep ^MemTotal | awk '{print $2}'`
free=`echo "$mem" | grep ^MemFree | awk '{print $2}'`
used=`echo $(( $total - $free ))`
buffers=`echo "$mem" | grep ^Buffers | awk '{print $2}'`
cached=`echo "$mem" | grep ^Cached: | awk '{print $2}'`
active=`echo "$mem" | grep ^Active: | awk '{print $2}'`
inactive=`echo "$mem" | grep ^Inactive: | awk '{print $2}'`

mqtt_publish "memory free" $free '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory used" $used '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory total" $total '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory active" $active '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory cached" $cached '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory buffers" $buffers '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '
mqtt_publish "memory inactive" $inactive '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "kB", '

nvram=`nvram show 2>&1 1>/dev/null | tr -cd ' 0-9'`
nv_used=`echo $nvram | awk '{print $1}'`
nv_free=`echo $nvram | awk '{print $2}'`
nv_total=`echo $(( $nv_used + $nv_free ))`

mqtt_publish "NVRAM free" $nv_free '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B", '
mqtt_publish "NVRAM used" $nv_used '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B", '
mqtt_publish "NVRAM total" $nv_total '"icon": "mdi:memory", "state_class": "measurement", "entity_category": "diagnostic", "device_class": "data_size", "unit_of_meas": "B", '
