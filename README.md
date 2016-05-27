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

AWS Image `ami-878412f4`

```
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04 LTS
Release:	16.04
Codename:	xenial

Linux ip-172-31-1-34 4.4.0-22-generic #40-Ubuntu SMP Thu May 12 22:03:46 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

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

## Testing alt.Dockerfile build
- needed java

```bash
git clone https://github.com/mhelvens/docker-node-neo4j-example.git
cd docker-node-neo4j-example/
git checkout sjn-0.1
git branch
git pull
ls -l
docker build --force-rm=true --file=alt.Dockerfile -t snewhouse/docker-node-neo4j-example:test-0.3 .
docker images
docker run --name docker-node-neo4j --publish=7474:7474 --publish=80:80 --volume=$HOME/neo4j/data:/data -d snewhouse/docker-node-neo4j-example:test-0.3
docker ps -a
CONTAINER_ID=$(docker ps | grep docker-node-neo4j | awk '{print $1}')
echo "${CONTAINER_ID}"
docker port ${CONTAINER_ID}
docker logs ${CONTAINER_ID}
docker stop ${CONTAINER_ID}
docker rm -f ${CONTAINER_ID}
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

d8b48cc029db8e14f7bdb39b079cce3ff83084e4f5bcd63444e0855cfc44001e

## Get Container Id

```bash
CONTAINER_ID=$(docker ps | grep docker-node-neo4j | awk '{print $1}')
echo "${CONTAINER_ID}"
```

`d8b48cc029db`

## Print logs and port output

```bash
docker logs ${CONTAINER_ID}
```

```
/usr/src/app/entrypoint.sh: line 3: /etc/init.d/neo4j-service: No such file or directory
npm info it worked if it ends with ok
npm info using npm@3.8.9
npm info using node@v6.2.0
npm info lifecycle docker-node-neo4j-example@0.1.0~prestart: docker-node-neo4j-example@0.1.0
npm info lifecycle docker-node-neo4j-example@0.1.0~start: docker-node-neo4j-example@0.1.0

> docker-node-neo4j-example@0.1.0 start /usr/src/app
> node src/server.js

Running on http://localhost:80
```

```bash
docker port ${CONTAINER_ID}
```
```
7474/tcp -> 0.0.0.0:7474
80/tcp -> 0.0.0.0:80
```

## curl it

```bash
curl -i  http://localhost:80
```

```
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Fri, 27 May 2016 11:08:39 GMT
Connection: keep-alive

Hello world!
```

**stop amd remove container**

```bash
## clean up
docker stop ${CONTAINER_ID} && docker rm -f ${CONTAINER_ID}
```
Done!

## Pushed to Docker hub

- https://hub.docker.com/r/snewhouse/docker-node-neo4j-example/tags/

```bash
docker push snewhouse/docker-node-neo4j-example:test-0.2
```

get me quick `docker pull snewhouse/docker-node-neo4j-example:test-0.2`

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

## New package.json

```
{
  "name": "docker-node-neo4j-example",
  "version": "0.1.0",
  "description": "an example docker image with a node.js server that uses neo4j",
  "main": "server.js",
  "scripts": {
    "start":        "node src/server.js"
  },
  "repository": {
    "type": "git",
    "url":  "git+https://github.com/mhelvens/docker-node-neo4j-example.git"
  },
  "author": "Michiel Helvensteijn <mhelvens@gmail.com>",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/mhelvens/docker-node-neo4j-example/issues"
  },
  "homepage": "https://github.com/mhelvens/docker-node-neo4j-example#readme",
  "dependencies": {
    "express": "^4.13.4"
  }
}
```
