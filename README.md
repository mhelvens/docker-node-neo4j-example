# docker-node-neo4j-example

This is an attempt to encapsulate a Node.js server and accompanying
Neo4j database together in a quick-to-deploy Docker image.

We used [this link](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
to figure out how to start.

### SJN test
Testing `master` branch build and adding a tweak: Check out [sjn_test.md](https://github.com/mhelvens/docker-node-neo4j-example/blob/sjn-0.1/sjn/sjn_test.md)

**links**  

- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/Dockerfile  
- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/docker-entrypoint.sh  


## Dev env details

Linux Image (Openstack) 


## New `docker-node-neo4j-example` Build

```bash
docker build \
--force-rm=true \
-t snewhouse/docker-node-neo4j-example:test-0.2 .
```

## Run it

```bash
docker run \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
-d snewhouse/docker-node-neo4j-example:test-0.2
```

## Get Container Id

```bash
docker ps
```

## New Dockerfile

```
FROM node:wheezy

# Create app directory with source-code
RUN mkdir -p /usr/src/app
COPY .       /usr/src/app
WORKDIR      /usr/src/app

# Install app dependencies
RUN npm install

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

VOLUME /data

# Expose ports
EXPOSE 80 
EXPOSE 7474

WORKDIR      /usr/src/app
# Start neo4j and node servers
CMD [ "/bin/bash", "/usr/src/app/entrypoint.sh" ] 
###, ["/bin/bash", "/usr/src/app/docker-entrypoint.sh", "neo4j" ]
```
