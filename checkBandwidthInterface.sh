#!/bin/sh

# Checks the number of bytes transferred on each interface. Ignores all interfaces from
# `/sys/class/net` which were added to the variable `ignore` (space separated) below.
# `listInterfaces.sh` shows a list of the interfaces.

. './common.sh'

# List of interfaces to exclude from monitoring
ignore='dpsta ifb0 ifb1 ifb2 ifb3 lo'

# Initialize stats file if it does not exist
[ ! -f "$net_stats_file" ] && touch "$net_stats_file"
now=$(date +%s)

# Read all interface data from /proc/net/dev in a single pass (highly efficient)
while read -r line; do
    # Skip headers: lines without a colon are ignored
    case "$line" in *:* ) ;; *) continue ;; esac

    # Ensure a space exists after the colon for reliable column splitting.
    # This fixes the issue where "vlan2:12345" would shift columns compared to "eth0: 12345".
    formatted_line=$(echo "$line" | sed 's/:/ /')
    set -- $formatted_line

    # After 'sed', the layout is: $1=iface, $2=rx_bytes, ..., $10=tx_bytes
    iface=$1
    rx_now=$2
    tx_now=${10}

    # Check if the current interface should be ignored[cite: 3]
    case " $ignore " in *" $iface "*) continue ;; esac

    # Retrieve previous stats for this interface from the cache file
    old_data=$(grep "^$iface " "$net_stats_file")

    if [ -n "$old_data" ]; then
        set -- $old_data
        # Variables: $1=iface, $2=old_timestamp, $3=old_rx_bytes, $4=old_tx_bytes
        time_diff=$(( now - $2 ))

        # Calculate bitrate if at least 1 second has passed
        if [ "$time_diff" -gt 0 ]; then
            # Formula: (Delta_Bytes * 8 bits) / Delta_Time = bit/s
            rx_rate=$(awk "BEGIN {printf \"%.2f\", ($rx_now - $3) * 8 / $time_diff}")
            tx_rate=$(awk "BEGIN {printf \"%.2f\", ($tx_now - $4) * 8 / $time_diff}")

            # Prepare technical name for MQTT (replace dots with underscores)
            if_name=$(echo "$iface" | tr '.' '_')

            # Publish rates to MQTT broker
            mqtt_publish -g 'network' -n "$if_name rx bitrate" -f "network $iface rx bitrate" -s "$rx_rate" -o '"ic":"mdi:download-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_rate","unit_of_meas":"bit/s"'
            mqtt_publish -g 'network' -n "$if_name tx bitrate" -f "network $iface tx bitrate" -s "$tx_rate" -o '"ic":"mdi:upload-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_rate","unit_of_meas":"bit/s"'
#            mqtt_publish -g 'network' -n "$if_name receive" -f "network $iface receive" -s "$rx_now" -o '"ic":"mdi:download-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
#            mqtt_publish -g 'network' -n "$if_name transmit" -f "network $iface transmit" -s "$tx_now" -o '"ic":"mdi:upload-network","stat_cla":"measurement","ent_cat":"diagnostic","dev_cla":"data_size","unit_of_meas":"B"'
        fi
    fi

    # Append current stats to a variable for a single bulk write operation
    new_stats="${new_stats}${iface} ${now} ${rx_now} ${tx_now}\n"
done < /proc/net/dev

# Write all updated stats to the RAM-disk file at once (minimizes I/O load)[cite: 3]
echo -e "$new_stats" > "$net_stats_file"
