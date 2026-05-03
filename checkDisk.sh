#!/bin/sh

# Checks some memory informations of attached disk(s). Add the disks of interest to the
# variable `disks` (space separated) in `config.sh` and make sure they are mounted.
# Find the path(s) to be added using the last column of the `df` command output.

. './common.sh'

for i in $disks; do
    read -r total used free usage part <<EOF
$(df | awk -v disk="$i" '$0 ~ disk {
    split($NF, path, "/");
    u = $5; gsub(/%/, "", u);
    print $2, $3, $4, u, path[length(path)];
    exit
}')
EOF

    ## skip invalid disk names
    [ "$part" = '' ] && continue

    mqtt_publish -g 'disk' -n "$part used" -s "$used" -o '"ic":"mdi:harddisk","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
    mqtt_publish -g 'disk' -n "$part free" -s "$free" -o '"ic":"mdi:harddisk","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
    mqtt_publish -g 'disk' -n "$part total" -s "$total" -o '"ic":"mdi:harddisk","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
    mqtt_publish -g 'disk' -n "$part usage" -s "$usage" -o '"ic":"mdi:harddisk","stat_cla":"measurement","ent_cat":"diagnostic","unit_of_meas":"%"'
done
