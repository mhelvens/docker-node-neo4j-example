#!/bin/bash

IMAGE=$1
TAG=$2

docker run --publish=7474:7474 --publish=80:80 --volume=${HOME}/neo4j/data:/data -d ${IMAGE}:${2}
