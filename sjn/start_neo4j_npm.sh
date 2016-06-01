#!/bin/bash -x

RUNDATE=`date +"%d%m%y"`
DATEHASH=`date | md5sum | cut -c 1-6`

cd /usr/src/app
echo "moving to [/usr/src/app]" > /scratch/start.npm.${RUNDATE}.${DATEHASH}.log
echo "running nohup npm start"  >> /scratch/start.npm.${RUNDATE}.${DATEHASH}.log
nohup npm start >> /scratch/start.npm.${RUNDATE}.${DATEHASH}.log &

cd /var/lib/neo4j
echo "moving to /var/lib/neo4j" > /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log
sleep 2s

echo "running /bin/bash /usr/local/bin/docker-entrypoint.sh neo4j" >> /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log

/bin/bash /usr/local/bin/docker-entrypoint.sh neo4j | tee -a /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log
