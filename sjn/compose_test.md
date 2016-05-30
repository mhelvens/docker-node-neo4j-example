## compose test

```
 node:
  build: ./node
  volumes:
    - "./app:/src/app"
  ports:
    - "80:80"
  links:
    - "db:redis"
  command: nodemon -L app/bin/www

neo4j:
  build: ./neo4j/
  ports:
    - "8080:8080"
  volumes:
    - /www/public
  volumes_from:
    - node
  links:
    - node:node
```


npm install request
npm install node-neo4j



```
FROM node:wheezy

# Create app directory with source-code
RUN mkdir -p /usr/src/app
COPY .       /usr/src/app
WORKDIR      /usr/src/app

# Install app dependencies
RUN npm install
RUN npm install request 
RUN npm install node-neo4j --save

# Install Neo4j
WORKDIR /root
ENV NEO4J_VERSION 2.3.3
ENV NEO4J_EDITION community
ENV NEO4J_DOWNLOAD_SHA256 01559c55055516a42ee2dd100137b6b55d63f02959a3c6c6db7a152e045828d9
ENV NEO4J_DOWNLOAD_ROOT http://dist.neo4j.org
ENV NEO4J_TARBALL neo4j-$NEO4J_EDITION-$NEO4J_VERSION-unix.tar.gz
ENV NEO4J_URI $NEO4J_DOWNLOAD_ROOT/$NEO4J_TARBALL

RUN curl --fail --silent --show-error --location --output neo4j.tar.gz $NEO4J_URI \
#  && echo "$NEO4J_DOWNLOAD_SHA256 neo4j.tar.gz" | sha256sum --check --quiet - \
    && tar --extract --file neo4j.tar.gz --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm neo4j.tar.gz

WORKDIR /var/lib/neo4j

RUN mv data /data \
    && ln --symbolic /data
    
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY start_apps.sh /opt/start_apps.sh

# Volumes
VOLUME /data
VOLUME /usr/src/app

# Expose ports
EXPOSE 80 
EXPOSE 6001
EXPOSE 5001
EXPOSE 7474 7473

# WORKDIR      /usr/src/app
# WORKDIR /root
# Start neo4j and node servers
CMD [ "/bin/bash", "/opt/start_apps.sh"] 
```

******** 

start_apps.sh

```
#!/usr/bin/env bash
npm start && \
/bin/bash /docker-entrypoint.sh neo4j
```


```
  #  setting "org.neo4j.server.webserver.address" "0.0.0.0" neo4j-server.properties
  #  setting "org.neo4j.server.database.mode" "${NEO4J_DATABASE_MODE:-}" neo4j-server.properties
  #  setting "ha.server_id" "${NEO4J_SERVER_ID:-}" neo4j.properties
  #  setting "ha.server" "${NEO4J_HA_ADDRESS:-}:6001" neo4j.properties
  #  setting "ha.cluster_server" "${NEO4J_HA_ADDRESS:-}:5001" neo4j.properties
  # setting "ha.initial_hosts" "${NEO4J_INITIAL_HOSTS:-}" neo4j.properties
 
 ``` 