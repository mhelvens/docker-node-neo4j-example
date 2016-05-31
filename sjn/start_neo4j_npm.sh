#!/usr/bin/env bash

RUNDATE=`date +"%d%m%y"`
DATEHASH=`date | md5sum | cut -c 1-6`

cd /usr/src/app
nohup npm start > /scratch/start.npm.${RUNDATE}.${DATEHASH}.log &

cd /var/lib/neo4j
nohup /bin/bash /docker-entrypoint.sh neo4j > /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log &

