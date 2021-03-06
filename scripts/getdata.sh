#!/bin/bash

# main Docker script has already created these:
export TOOLS=/mnt/tools
export DATA=/mnt/data
SCRIPTS=$TOOLS/scripts

#==============
# Download data
#==============

#run multiple downloads in parallel to save time
$SCRIPTS/oa-loader.sh &
$SCRIPTS/osm-loader.sh &
$SCRIPTS/gtfs-loader.sh &
$SCRIPTS/geonames-loader.sh &

#launch also Elasticsearch at this point
$SCRIPTS/start-ES.sh &

#sync
wait

ok_count=$(cat /tmp/loadresults | grep 'OK' | wc -l )
if [ $ok_count -ne 5 ]; then
    echo 'Data loading failed'
    exit 1;
fi

#=================
# Index everything
#=================

#run two imports in parallel to save time
$SCRIPTS/index1.sh &
$SCRIPTS/index2.sh &

wait

ok_count=$(cat /tmp/indexresults | grep 'OK' | wc -l )
if [ $ok_count -ne 2 ]; then
    echo 'Indexing failed'
    exit 1;
fi

#=======
#cleanup
#=======

#shutdown ES in a friendly way
pkill -SIGTERM -u elasticsearch
sleep 3

rm -r $DATA
rm -r $TOOLS
dpkg -r nodejs
apt-get purge -y git unzip zip python python-pip python-dev build-essential gdal-bin rlwrap
apt-get clean
rm -rf /tmp/*
