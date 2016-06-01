# SJN Looksee




new testing in `sjn/Dockerfile`  

moved to AWS as mac is running out of space v quickly when it comes to dev.

```bash
cd sjn/
docker build --rm=true -t snewhouse/node-neo4j:alpha-07 .
```

```bash
##
docker run \
--rm=true \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-it snewhouse/node-neo4j:alpha-06 
```

## above works. I can ssh into it and start node and neo4j

```
/var/lib/neo4j/data/log was missing, recreating...
2016-06-01 12:37:04.557+0000 INFO  No SSL certificate found, generating a self-signed certificate..
2016-06-01 12:37:07.108+0000 INFO  Successfully started database
2016-06-01 12:37:07.130+0000 INFO  Starting HTTP on port 7474 (8 threads available)
2016-06-01 12:37:07.247+0000 INFO  Enabling HTTPS on port 7473
2016-06-01 12:37:07.303+0000 INFO  Mounting static content at /webadmin
2016-06-01 12:37:07.337+0000 INFO  Mounting static content at /browser
2016-06-01 12:37:08.177+0000 INFO  Remote interface ready and available at http://0.0.0.0:7474/

sjnewhouse@MacBook-Pro-6:~/scratch|⇒  more start.npm.010616.cb2908.log

> docker-node-neo4j-example@0.1.0 start /usr/src/app
> node src/server.js

Running on http://localhost:80
sjnewhouse@MacBook-Pro-6:~/scratch|⇒  curl -i http://192.168.99.100:80
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Wed, 01 Jun 2016 12:40:53 GMT
Connection: keep-alive

Hello world!
```

building image with `CMD ["/bin/bash","/start_neo4j_npm.sh"]` 

```bash
cd sjn/
docker build --rm=true -t snewhouse/node-neo4j:alpha-07 .
```

this dont work

```bash
docker run \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-07

docker ps -a

curl -i http://192.168.99.100:80
```

try 

```bash
docker run \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-07 /bin/bash /start_neo4j_npm.sh

docker ps -a

curl -i http://192.168.99.100:80
```

nope! 

so ...te

building image with 

```
ENTRYPOINT ["/bin/bash"]
CMD ["start_neo4j_npm.sh"]
```

```
#!/bin/bash

RUNDATE=`date +"%d%m%y"`
DATEHASH=`date | md5sum | cut -c 1-6`

cd /usr/src/app
echo "moving to [/usr/src/app]" > /scratch/start.npm.${RUNDATE}.${DATEHASH}.log
echo "running nohup npm start"  >> /scratch/start.npm.${RUNDATE}.${DATEHASH}.log
nohup npm start >> /scratch/start.npm.${RUNDATE}.${DATEHASH}.log &

cd /var/lib/neo4j
echo "moving to /var/lib/neo4j" > /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log
echo "running /bin/bash /usr/local/bin/docker-entrypoint.sh neo4j" >> /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log
nohup /bin/bash /usr/local/bin/docker-entrypoint.sh neo4j >> /scratch/start.neo4j.${RUNDATE}.${DATEHASH}.log &

```

and moved scripts to `/usr/local/bin/` in build

`COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh`
`COPY start_neo4j_npm.sh /usr/local/bin/start_neo4j_npm.sh`

`rm` and `build`

so above dont work now reverting back to:

`CMD ["/bin/bash"]`

scripts still in 

`COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh`
`COPY start_neo4j_npm.sh /usr/local/bin/start_neo4j_npm.sh`

```bash
cd sjn/
clear_docker_mess rmdcontainer
clear_docker_mess rmdimages
docker rmi -f snewhouse/node-neo4j:alpha-08
docker build --rm=true -t snewhouse/node-neo4j:alpha-08 .
```


```bash
docker run \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-it snewhouse/node-neo4j:alpha-08 /bin/bash -c "/usr/local/bin/start_neo4j_npm.sh"


watch docker ps -a

```

balls! New changes.....

see : http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/#difference_between_cmd_and_entrypoint "Hack to run container in the background"

removed `nohup`

container stops with call to nohup i think and shuts down.

>Docker requires your command to keep running in the foreground. Otherwise, it thinks that your applications stops and shutdown the container


```
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

```


```bash
cd sjn/
clear_docker_mess rmdcontainer
clear_docker_mess rmdimages
docker rmi -f snewhouse/node-neo4j:alpha-08
docker build --rm=true -t snewhouse/node-neo4j:alpha-08 .
```


```bash
docker run \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-08 /bin/bash -c "/usr/local/bin/start_neo4j_npm.sh"


watch docker ps -a

```

```
curl -i http://192.168.99.100:80
```

ABOVE WORKS!!!!

NOW....

cp Dockerfile **`app.Dockerfile`**

change:- 

`ENTRYPOINT ["/bin/bash","/usr/local/bin/start_neo4j_npm.sh"]`

uses new `start_neo4j_npm.sh`

FIX: `/bin/bash /usr/local/bin/docker-entrypoint.sh neo4j`. NO NOHUP. MUST RUN IN FOREGROUND TO KEEP ALIVE


```bash
cd sjn/
clear_docker_mess rmdcontainer
clear_docker_mess rmdimages

docker build --rm=true --file=app.Dockerfile -t snewhouse/node-neo4j:alpha-09 .
```


```bash
docker run \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-09


watch docker ps -a

```

Fuck yeah!

```
⇒  docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                                      NAMES
484d84435c22        snewhouse/node-neo4j:alpha-09   "/bin/bash /usr/local"   7 seconds ago       Up 6 seconds        5001/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:7473-7474->7473-7474/tcp, 6001/tcp   lonely_swartz


⇒  docker port 484d84435c22
7474/tcp -> 0.0.0.0:7474
80/tcp -> 0.0.0.0:80
7473/tcp -> 0.0.0.0:7473

⇒  docker logs 484d84435c22
npm info it worked if it ends with ok
npm info using npm@3.8.9
npm info using node@v6.2.0
npm info lifecycle docker-node-neo4j-example@0.1.0~prestart: docker-node-neo4j-example@0.1.0
npm info lifecycle docker-node-neo4j-example@0.1.0~start: docker-node-neo4j-example@0.1.0
Starting Neo4j Server console-mode...
2016-06-01 14:09:36.025+0000 INFO  No SSL certificate found, generating a self-signed certificate..
2016-06-01 14:09:38.461+0000 INFO  Successfully started database
2016-06-01 14:09:38.481+0000 INFO  Starting HTTP on port 7474 (8 threads available)
2016-06-01 14:09:38.607+0000 INFO  Enabling HTTPS on port 7473
2016-06-01 14:09:38.660+0000 INFO  Mounting static content at /webadmin
2016-06-01 14:09:38.690+0000 INFO  Mounting static content at /browser
2016-06-01 14:09:39.492+0000 INFO  Remote interface ready and available at http://0.0.0.0:7474/


⇒  curl -i http://192.168.99.100:80
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Wed, 01 Jun 2016 14:10:47 GMT
Connection: keep-alive

Hello world!
sjnewhouse@MacB
```


```
curl -i http://192.168.99.100:80
```


********************

## OLD

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

