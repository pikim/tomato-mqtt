#!/bin/sh

## any additional mount points to monitor here, space delimited like "/jffs /nfs"
disks="/tmp/mnt/sda1"

## MQTT connection settings
port="1883"
addr="your_hassos_address"
username="your_ha_mqtt_username"
password="your_ha_mqtt_password"

## REST connection settings
ifport="8123"
ifserver="your_hassos_address"
iftoken="your_unique_token"
