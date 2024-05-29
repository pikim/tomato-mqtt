# tomato-mqtt

Scripts to capture metrics from routers running FreshTomato. Developped for Home Assistant with MQTT plugin (supports discovery).

Developped on Netgear R6400. Based on *tomato-grafana* by Andrej Walilko (https://github.com/ch604/tomato-grafana).


## Features

- transfers data using cURL and MQTT and supports MQTT discovery on Home Assistant
- collects various router metrics and sends them to a Home Assistant server
- the router pushes and pulls data - without exposing any interface on router side
- allows to enable/disable access restriction rules from within Home Assistant
- allows to enable/disable the adblocker from within Home Assistant
- allows to track the connection state of clients


## Requirements

- Router running FreshTomato (tested on 2023.2)
- Server running MQTT (and Home Assistant)


## Installation

### entware and dependencies

Connect and mount a USB drive to the FreshTomato router
```
mount --bind /tmp/mnt/sda1 /opt
```
To automatically mount the drive, activate `automount` on the `USB support` page and add the above line to `Run after mounting`.

Install entware
```
/usr/sbin/entware-install.sh
```

Update, upgrade and install the required package(s)
```
opkg update
opkg upgrade
opkg install coreutils-readlink
opkg install mosquitto-client-nossl
opkg install jq
```

See also https://wiki.freshtomato.org/doku.php/entware_installation_usage

### tomato-mqtt

Copy this whole repo into `/opt`. We assume that it resides in `/opt/tomato-mqtt/` then.

For speedtest results, download the Ookla ARM CLI tool from https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-arm-linux.tgz and place its contents in a folder called `/opt/speedtest/`. The core speedtest binary (`/opt/speedtest/speedest`) should be executable.

Modify the MQTT connection settings in `config.sh` according to your server. Also add any additional mount points you may want to monitor under `disks` in this file (space-delimited). The scripts do not have to be executable. Check the first couple of lines in `common.sh` whether they seem plausible to you.

Add the following command under `Administration` -> `Scheduler` as custom cron job:
```
sh /opt/tomato-mqtt/collectorStart.sh >/dev/null 2>&1
```
It should run every 1 minute on every day of the week. The collectors will now run every 20 or 30 seconds. You can adjust the interval in `collectorStart.sh`.

Additionally, add this cron for the speedtest:
```
sh /opt/tomato-mqtt/speedTestStart.sh >/dev/null 2>&1
```
Run this every 30 minutes, or as often as you would like results recorded.

Enjoy having the data on your MQTT server!


## Implementation details

The scripts collect the relevant data on the router itself. When data preparation has finished the data is transferred via MQTT. The function `fetch_entities` in `common.sh` will request the state of all device entities from Home Assistant. This happens by using a template sensor which defined in `template.twig`. Home Assistant will reply with a json structure that contains the entity names and friendly names of all dedicated entities. The json also will contain the IP addresses of the address leases and the state of the access rule and adblock switches. The file can be found in `/tmp` until the router is rebooted.

`checkAccessRestriction.sh` and `checkAdBlock.sh` use the state data to control the corresponding rules/service. If the desired state (on Home Assistant) differs from the current state (on router) the according rule or service is updated and applied.

### MQTT

See https://www.home-assistant.io/integrations/mqtt for details about MQTT, discovery and `mosquitto_pub` in conjunction with Home Assistant.

Generally, it would also be possible to use the Home Assistant REST API. But (currently) this does neither support devices, nor unique IDs. Therefore MQTT is used to minimize the configuration effort on Home Assistant side.

### REST

See https://developers.home-assistant.io/docs/api/rest for details about the REST API.

### Template

See https://www.home-assistant.io/docs/configuration/templating/#devices for details about template sensors.


## Troubleshooting

Enter the directoy (`cd /opt/tomato-mqtt`) and execute the scripts manually, e.g. `sh checkCPU.sh` to see error messages. Don't forget to check the MQTT section in Home Assistant afterwards - the device and entities should have been created or updated. For debugging it can be helpful to add a `echo` call to print the content of a variable in the console, e.g.
```
cpuTemp=$(grep -o '[0-9]\+' /proc/dmu/temperature)
echo "$cpuTemp"
```

## Deletion

`removeEntities.sh` can delete all topics within the file, e.g.
```
sh /opt/tomato-mqtt/removeEntities.sh FreshTomato_R7000.txt
```
It also allows to delete only a single topic, e.g.
```
sh /opt/tomato-mqtt/removeEntities.sh homeassistant/sensor/CPU_temperature/config
```

Note: the file `FreshTomato_R7000.txt` is not used any more.
