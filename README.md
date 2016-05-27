# docker-node-neo4j-example

This is an attempt to encapsulate a Node.js server and accompanying
Neo4j database together in a quick-to-deploy Docker image.

We used [this link](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
to figure out how to start.

### SJN test
Testing `master` branch build and adding a tweak: Check out [sjn_test.md](https://github.com/mhelvens/docker-node-neo4j-example/blob/sjn-0.1/sjn/sjn_test.md)

**links**  

- http://neo4j.com/developer/docker/  
- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/Dockerfile  
- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/docker-entrypoint.sh  


## Dev env details

Linux Image (Openstack) 

```
Description:	Ubuntu 16.04 LTS
Release:	16.04
Codename:	xenial

Linux sjn-devbox-ubuntu 4.4.0-22-generic #40-Ubuntu SMP Thu May 12 22:03:46 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

## docker
Client:
 Version:      1.11.1
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   5604cbe
 Built:        Tue Apr 26 23:43:49 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.11.1
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   5604cbe
 Built:        Tue Apr 26 23:43:49 2016
 OS/Arch:      linux/amd64
```

## New Build

```bash
docker build \
--force-rm=true \
-t snewhouse/docker-node-neo4j-example:test-0.2 .
```

## Run it

```bash
docker run \
--name docker-node-neo4j \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
-d snewhouse/docker-node-neo4j-example:test-0.2
```

## Get Container Id

```bash
CONTAINER_ID=$(docker ps | grep docker-node-neo4j | awk '{print $1}')
```

## Print output

```bash
docker logs ${CONTAINER_ID}
```

## curl it

```bash
curl -i  http://localhost:80
```

*******

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
