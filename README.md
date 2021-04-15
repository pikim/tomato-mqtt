# tomato-grafana

Scripts to display metrics from routers running FreshTomato. Developed on Netgear R7000.

Based on dd-wrt-grafana by Trevor Dodds (https://grafana.com/grafana/dashboards/950), updated for influxdb and freshtomato.

# Requirements

- Router running FreshTomato (tested on 2021.2)
- Server running Grafana
- Server running InfluxDB with auth-enabled=true

# Installation

Enable JFFS support on Tomato under Administration -> JFFS.

Upload all shell scripts to /jffs/tomato-grafana/. Modify the IP, port, password, and username of your influxdb server in variables.sh

Add the following three commands under Administration -> Scheduler as custom cron jobs:
```
sh /jffs/tomato-grafana/collector.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector20.sh >/dev/null 2>&1
sh /jffs/tomato-grafana/collector40.sh >/dev/null 2>&1
```
These should all run every 1 minute on every day of the week.

Import Grafana json dashboard: https://grafana.com/grafana/dashboards/14237

Enjoy.
