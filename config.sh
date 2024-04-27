#!/bin/sh

## any additional mount points to monitor here, space delimited like "/jffs /nfs"
disks="/tmp/mnt/sda1"

## MQTT connection settings
port="1883"
addr="your_hassos_address"
username="your_ha_mqtt_username"
password="your_ha_mqtt_password"

## REST API connection settings
ra_port="8123"
ra_addr="your_hassos_address"
ra_token="your_unique_token"
