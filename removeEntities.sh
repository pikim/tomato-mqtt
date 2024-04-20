#!/bin/sh

source variables.sh

if [ -f "$1" ]; then
    echo "removing all sensors in $1"
    while IFS="" read -r p || [ -n "$p" ]
    do
#        printf '%s\n' "$p"
        mosquitto_pub -h $addr -p $port -u $username -P $password -t "$p" -m '' 
    done < $1

    echo "Sensors from '$1' have been deleted."
    echo -n "Do you wish to delete the file? (y/n) "
    read -r selection

    if [ "$selection" = "y" ]; then
#        echo "file deleted"
        rm $1 
    fi
else
    echo "removing single sensor $1"
    mosquitto_pub -h $addr -p $port -u $username -P $password -t "$1" -m ''
fi