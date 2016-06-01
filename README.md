# docker-node-neo4j-example

This is an attempt to encapsulate a Node.js server and accompanying
Neo4j database together in a quick-to-deploy Docker image.

We used [this link](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
to figure out how to start.

******************

## SJN Final

get it quick...got it working (I hope)..

```bash
docker pull snewhouse/node-neo4j:alpha-01
```

**build from scratch:**

### Build it

```bash
docker build --rm=true --file=app.Dockerfile -t snewhouse/node-neo4j:alpha-01 .
```

### Run it

```bash
## make dirs if ya need
# mkdir -p $HOME/neo4j/data
# mkdir -p $HOME/scratch

## run it
docker run \
--name node-neo4-app-01 \
--publish=7473:7473 \
--publish=7474:7474 \
--publish=80:80 \
--volume=$HOME/neo4j/data:/data \
--volume=$HOME/scratch:/scratch \
-d snewhouse/node-neo4j:alpha-01
```

### Is it running?

```bash
docker ps -a
```

```
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                                      NAMES
ff594447ab48        snewhouse/node-neo4j:alpha-01   "/bin/bash /usr/local"   5 seconds ago       Up 5 seconds        5001/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:7473-7474->7473-7474/tcp, 6001/tcp   node-neo4-app-01
```

### Test it

```bash
CONTAINER_ID=$(docker ps | grep node-neo4-app-01 | awk '{print $1}')
echo "${CONTAINER_ID}"
docker port ${CONTAINER_ID}
docker logs ${CONTAINER_ID}
```

```
sjnewhouse@MacBook-Pro-6:~/Google Drive/KHP_Informatics/docker-node-neo4j-example|sjn-0.1⚡
⇒  docker port ${CONTAINER_ID}
7473/tcp -> 0.0.0.0:7473
7474/tcp -> 0.0.0.0:7474
80/tcp -> 0.0.0.0:80
sjnewhouse@MacBook-Pro-6:~/Google Drive/KHP_Informatics/docker-node-neo4j-example|sjn-0.1⚡
⇒
sjnewhouse@MacBook-Pro-6:~/Google Drive/KHP_Informatics/docker-node-neo4j-example|sjn-0.1⚡
⇒  docker logs ${CONTAINER_ID}
npm info it worked if it ends with ok
npm info using npm@3.8.9
npm info using node@v6.2.0
npm info lifecycle docker-node-neo4j-example@0.1.0~prestart: docker-node-neo4j-example@0.1.0
npm info lifecycle docker-node-neo4j-example@0.1.0~start: docker-node-neo4j-example@0.1.0
Starting Neo4j Server console-mode...
2016-06-01 14:30:04.083+0000 INFO  No SSL certificate found, generating a self-signed certificate..
2016-06-01 14:30:06.473+0000 INFO  Successfully started database
2016-06-01 14:30:06.492+0000 INFO  Starting HTTP on port 7474 (8 threads available)
2016-06-01 14:30:06.604+0000 INFO  Enabling HTTPS on port 7473
2016-06-01 14:30:06.657+0000 INFO  Mounting static content at /webadmin
2016-06-01 14:30:06.688+0000 INFO  Mounting static content at /browser
2016-06-01 14:30:07.425+0000 INFO  Remote interface ready and available at http://0.0.0.0:7474/
```

### curl it

```bash
# linux
curl -i localhost:7474

# mac
curl -i http://192.168.99.100:80
```

```
⇒  curl -i http://192.168.99.100:80
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/html; charset=utf-8
Content-Length: 13
ETag: W/"d-WcoO+p9WM8sDcbvANVR42A"
Date: Wed, 01 Jun 2016 14:31:41 GMT
Connection: keep-alive

Hello world
```

### Commit and push it

```bash
CONTAINER_ID=$(docker ps | grep node-neo4-app-01 | awk '{print $1}')
echo "${CONTAINER_ID}"

docker commit ${CONTAINER_ID} snewhouse/node-neo4j:alpha-01
sha256:eb11a3cd92b4eb23e8d4ae80d10360a453738396fbc65d6d0df68805766905c1

docker push snewhouse/node-neo4j:alpha-01
```


**************************


### SJN test
Testing `master` branch build and adding a tweak: Check out [sjn_test.md](https://github.com/mhelvens/docker-node-neo4j-example/blob/sjn-0.1/sjn/sjn_test.md)

**links**  

- http://neo4j.com/developer/docker/  
- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/Dockerfile  
- https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/docker-entrypoint.sh  
- http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/#difference_between_cmd_and_entrypoint  
