#!/bin/bash

# errors should break the execution
set -e

cd /root

#start elasticsearch and create index
gosu elasticsearch elasticsearch -d

sleep 20

#schema script runs only from current dir
cd $TOOLS/schema/
node scripts/create_index.js

echo 'OK' >> /tmp/loadresults
