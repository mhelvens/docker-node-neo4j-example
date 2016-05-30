#!/usr/bin/env bash
/bin/bash /usr/src/app/entrypoint.sh && \
/bin/bash /docker-entrypoint.sh neo4j
