#!/bin/bash

plotcount=$(ps -ef | grep "plots create" | wc | awk {'print $1'})
if [ "$plotcount" -lt '4' ] ; then
#chia plots create -k 32 -b 4000 -t /chiacache -d /data
touch /home/seb/test.txt
else
:
fi

