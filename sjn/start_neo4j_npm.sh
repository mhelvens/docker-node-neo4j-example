#!/usr/bin/env bash
cd /var/lib/neo4j/ && \
  /bin/bash /docker-entrypoint.sh neo4j && \
  sleep 1s && \
  cd /usr/src/app && \
  npm start && \
  sleep 1s
