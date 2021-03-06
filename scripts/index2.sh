#!/bin/bash

# errors should break the execution
set -e 

# param: zip name containing gtfs data
function import_gtfs {
    unzip -q -o $1
    prefix=$(echo $1 | sed 's/.zip//g')
    prefix=${prefix^^}
    node $TOOLS/pelias-gtfs/import -d $DATA/gtfs --prefix=$prefix
}

pushd $TOOLS/geonames
echo '###### starting geonames import'
npm start
popd
echo '###### geonames done'

cd $DATA/gtfs

echo '###### indexing GTFS'
targets=(`ls *.zip`)
for target in "${targets[@]}"
do
    echo 'importing ' $target
    import_gtfs $target
done
echo '###### gtfs done'

echo '###### indexing openaddresses'
#import openaddresses data
cd  $TOOLS/openaddresses

bin/parallel 2 
echo '###### openaddresses/en done'

echo 'OK' >> /tmp/indexresults
