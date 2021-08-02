#!/bin/sh                                                                                                                               

source /jffs/tomato-grafana/variables.sh

[ ! -x /jffs/speedtest/speedtest ] && exit

result=`/jffs/speedtest/speedtest -f csv`
down=`echo "$result" | awk -F\" '{print $12}'`
up=`echo "$result" | awk -F\" '{print $14}'`

curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'speedtest.upload value='$up
curl -XPOST 'http://'$ifserver':'$ifport'/write?db='$ifdb -u $ifuser:$ifpass --data-binary 'speedtest.download value='$down
