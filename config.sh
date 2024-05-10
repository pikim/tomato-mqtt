#!/bin/sh

# Holds custom credentials, disks and hosts.
# !!! DO NOT SHARE THIS FILE WITH OTHER PERSONS !!!

## any additional mount points to monitor here, space delimited like "/jffs /nfs"
disks="/tmp/mnt/sda1"

## any additional hosts to ping here, space delimited like "www.google.com www.bing.com"
hosts="google.com"

## MQTT connection settings
port="1883"
addr="your_hassos_address"
username="your_ha_mqtt_username"
password="your_ha_mqtt_password"

## REST API connection settings
ra_port="8123"
ra_addr="your_hassos_address"
ra_token="your_unique_token"
