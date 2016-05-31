# SJN Looksee




new testing in `sjn/Dockerfile`  

```
docker build --rm=true -t snewhouse/node-neo4j:alpha-04 .
```

```
docker run \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/temp/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-04 /usr/src/app/start_neo4j_npm.sh  
```

```
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                        NAMES
087c867141f2        snewhouse/node-neo4j:alpha-02   "/bin/bash /usr/src/a"   20 seconds ago      Up 19 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:7474->7474/tcp   serene_pasteur
```

port

```
7474/tcp -> 0.0.0.0:7474
80/tcp -> 0.0.0.0:80
```

logs
```
> docker-node-neo4j-example@0.1.0 start /usr/src/app
> node src/server.js
```

`curl -i http://192.168.99.100:80`

```
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Tue, 31 May 2016 13:00:07 GMT
Connection: keep-alive

Hello world!
```


should get :

```
Starting Neo4j.
2016-05-31 13:26:35.118+0000 INFO  No SSL certificate found, generating a self-signed certificate..
2016-05-31 13:26:35.399+0000 INFO  Starting...
2016-05-31 13:26:35.742+0000 INFO  Bolt enabled on 0.0.0.0:7687.
2016-05-31 13:26:37.469+0000 INFO  Started.
2016-05-31 13:26:38.150+0000 INFO  Remote interface available at http://0.0.0.0:7474/
```

********************

On my macbook:

```
Darwin MacBook-Pro-6.local 15.4.0 Darwin Kernel Version 15.4.0: Fri Feb 26 22:08:05 PST 2016; root:xnu-3248.40.184~3/RELEASE_X86_64 x86_64
```

## git clone

```bash
git clone https://github.com/mhelvens/docker-node-neo4j-example.git
cd docker-node-neo4j-example
```

## Build image first

Just tetsing docker build here..and all good

```bash
docker build -t mhelvens/docker-node-neo4j-example .
docker images
```

```
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
mhelvens/docker-node-neo4j-example   latest              4317be95c007        36 minutes ago      919.1 MB
```


## Edit package.json

saw you were requesting docker run and build from `package.json`. not sure about this so I :-


removed

```
    "docker-build": "docker build -t mhelvens/docker-node-neo4j-example .",
    "docker-run":   "docker run -p 80:80 -p 7474:7474 -d mhelvens/docker-node-neo4j-example"
```

and made a new `package.json`

```
{
  "name": "docker-node-neo4j-example",
  "version": "0.1.0",
  "description": "an example docker image with a node.js server that uses neo4j",
  "main": "server.js",
  "scripts": {
    "start":        "node src/server.js",
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

## run a test

Giving it a whirl....

```
mkdir -p test
touch ./test/test.sh

echo -e "
docker run \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
-d mhelvens/docker-node-neo4j-example:latest" >> ./test/test.sh

chmod 755 ./test/test.sh
```


```bash
bash ./test/test.sh
```

```
4de73596de996f0c8d61b14707a309759598a1b36dd7403f9e60f0cc4948d402
```


## Get container ID

```bash
# Get container ID
docker ps
```

```
CONTAINER ID        IMAGE                                       COMMAND                  CREATED             STATUS              PORTS                                        NAMES
4de73596de99        mhelvens/docker-node-neo4j-example:latest   "/bin/bash entrypoint"   59 seconds ago      Up 58 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:7474->7474/tcp   jovial_heyrovsky
```


## Print app output

```bash
docker logs 4de73596de99
```


```
Starting Neo4j Server...WARNING: not changing user
process [135]... waiting for server to be ready.... OK.
http://localhost:7474/ is ready.
npm info it worked if it ends with ok
npm info using npm@3.8.9
npm info using node@v6.2.0
npm info lifecycle docker-node-neo4j-example@0.1.0~prestart: docker-node-neo4j-example@0.1.0
npm info lifecycle docker-node-neo4j-example@0.1.0~start: docker-node-neo4j-example@0.1.0

> docker-node-neo4j-example@0.1.0 start /usr/src/app
> node src/server.js

Running on http://localhost:80
```


On Mac-OSX go to http://$(docker-machine ip default):80. (http://neo4j.com/developer/docker/)

```bash
echo $(docker-machine ip default)
```
`192.168.99.100`


## curl it

```bash
curl -i http://192.168.99.100:80
```
and all groovy

```
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Thu, 26 May 2016 11:06:52 GMT
Connection: keep-alive

Hello world!
```
