#!/usr/bin/env bash
cd /var/lib/neo4j/ && \
  /bin/bash /docker-entrypoint.sh neo4j | tee -a /sracth/start.log & \
  sleep 5s && \
  cd /usr/src/app && \
  npm start | tee -a /sracth/start.log && \
  sleep 1s
