#!/bin/sh

source /jffs/dd-wrt-grafana/variables.sh

cpu=`cat /proc/stat | head -n1 | sed 's/cpu //'`
user=`echo $cpu | awk '{print $1}'`
nice=`echo $cpu | awk '{print $2}'`
system=`echo $cpu | awk '{print $3}'`
idle=`echo $cpu | awk '{print $4}'`
iowait=`echo $cpu | awk '{print $5}'`
irq=`echo $cpu | awk '{print $6}'`
softirq=`echo $cpu | awk '{print $7}'`
steal=`echo $cpu | awk '{print $8}'`
guest=`echo $cpu | awk '{print $9}'`
guest_nice=`echo $cpu | awk '{print $10}'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.user value='$user
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.nice value='$nice
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.system value='$system
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.idle value='$idle
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.iowait value='$iowait
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.irq value='$irq
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.softirq value='$softirq
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.steal value='$steal
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.guest value='$guest
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'cpu.guest_nice value='$guest_nice
