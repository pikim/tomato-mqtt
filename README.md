# tomato-grafana

Scripts to display metrics from routers running FreshTomato. Developed on Netgear R7000.

![Dashboard Preview](https://i.imgur.com/fR4c8LC.png)

Based on dd-wrt-grafana by Trevor Dodds (https://grafana.com/grafana/dashboards/950), updated for influxdb and freshtomato.

# Requirements

- Router running FreshTomato (tested on 2021.2)
- Server running Grafana
- Server running InfluxDB

# Installation

Enable auth on InfluxDB (on my apt-based debian install, this was at /etc/influxdb/influxdb.conf) and configure a user and password. The router scripts will expect auth for depositing data.

Set up a blank InfluxDB database for storage (after installing influxdb-client, auth into influx from the command line, and run "CREATE DATABASE tomato", or whatever you would like to call it).

Connect Grafana to InfluxDB as a data source using the same username and password you set up for influx auth.

On to the router. Enable JFFS support on Tomato under Administration -> JFFS.

Upload all shell scripts to /jffs/tomato-grafana/. Modify the IP, port, password, and username of your influxdb server in variables.sh.

Add the following three commands under Administration -> Scheduler as custom cron jobs:
```
sh /jffs/tomato-grafana/collector.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector20.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector40.sh >/dev/null 2>&1
```
These should all run every 1 minute on every day of the week. The collectors will now run every 20 seconds.

Import the Grafana dashboard via json file or from this dashboard code: https://grafana.com/grafana/dashboards/14237

Enjoy!
