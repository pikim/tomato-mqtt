# tomato-mqtt

Scripts to capture metrics from routers running FreshTomato. Developped for HomeAssistant with MQTT plugin (supports discovery). With slight modifications it should also run without HomeAssistant.

Developped on Netgear R6400. Based on *tomato-grafana* by Andrej Walilko (https://github.com/ch604/tomato-grafana).

## Features

- transfers data using MQTT and supports MQTT discovery on HomeAssistant
- collects various router metrics and sends them to a HomeAssistant server
- the router pushes and pulls data - without exposing any interface on router side
- allows to enable/disable access restriction rules from within HomeAssistant
- allows to enable/disable the adblocker from within HomeAssistant (upcoming feature)

## Requirements

- Router running FreshTomato (tested on 2023.2)
- Server running MQTT (and HomeAssistant)

## Installation

### mosquitto-client

Connect and mount a USB drive to the FreshTomato router
```
mount --bind /tmp/mnt/sda1 /opt
```

Install entware
```
/usr/sbin/entware-install.sh
```

Update, upgrade and install the desired package(s)
```
opkg update
opkg upgrade
opkg install coreutils-readlink
opkg install mosquitto-client-nossl
```

see also https://wiki.freshtomato.org/doku.php/entware_installation_usage

### tomato-mqtt

Copy this whole repo into `/opt`. We assume that it resides in `/opt/tomato-mqtt/` then.

For speedtest results, download the Ookla ARM CLI tool from https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-arm-linux.tgz and place its contents in a folder called `/opt/speedtest/`. The core speedtest binary (`/opt/speedtest/speedest`) should be executable.

Modify the MQTT connection settings in `config.sh` according to your server. Also add any additional mount points you may want to monitor under `disks` in this file (space-delimited). The scripts do not have to be executable.

Add the following command under `Administration` -> `Scheduler` as custom cron job:
```
sh /opt/tomato-mqtt/collectorStart.sh >/dev/null 2>&1
```
It should run every 1 minute on every day of the week. The collectors will now run every 20 or 30 seconds. You can adjust the interval in `collectorStart.sh`.

Additionally, add this cron for the speedtest:
```
sh /opt/tomato-mqtt/speedTest.sh >/dev/null 2>&1
```
Run this every 30 minutes, or as often as you would like results recorded.

Enjoy having the data on your MQTT server!

## Implementation details

Generally, it would also be possible to use the HomeAssistant REST API. But (currently) this does neither support devices, nor unique IDs. Therefore MQTT is used to minimize the configuration effort on HomeAssistant side.

The function `mqtt_publish` in `variables.sh` will build a text file that contains already registered MQTT topics. If a topic doesn't exist yet, an according discovery message is sent and the topic is appended to the file. Afterwards `mqtt_publish` transfers the topic data. If a topic was already appended to the text file before, `mqtt_publish` only transfers the data without sending another discovery message.

The text file also allows to check which topics do exists.

See https://www.home-assistant.io/integrations/mqtt for details about MQTT, discovery and `mosquitto_pub` in conjunction with HomeAssistant.

## Deletion

The above mentioned text file can also be used if you want to delete all the topics.

`removeEntities.sh` can delete all topics within the file, e.g.
```
sh /opt/tomato-mqtt/removeEntities.sh FreshTomato_R7000.txt
```
but it also allows to delete only a single topic, e.g.
```
sh /opt/tomato-mqtt/removeEntities.sh homeassistant/sensor/CPU_temperature/config
```
