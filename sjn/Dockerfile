FROM node:wheezy

MAINTAINER Stephen J Newhouse <stephen.j.newhouse@gmail.com>

################################################################################
# update and get java
#
RUN apt-get update --fix-missing && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    openjdk-7-jre && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################################################################################
# Create app directory with source-code
#
RUN mkdir -p /usr/src/app
COPY .       /usr/src/app
WORKDIR      /usr/src/app

################################################################################
# Install app dependencies
#
RUN npm install
RUN npm install node-neo4j

################################################################################
# Install Neo4j
# taken from dockerhub build for neo4j
# https://hub.docker.com/_/neo4j/
# https://github.com/neo4j/docker-neo4j/blob/89955a10604656aa8def4e3d658cc870818d7535/2.3.3/Dockerfile
#
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

RUN mv data /data && \
  ln --symbolic /data

COPY docker-entrypoint.sh /docker-entrypoint.sh

# fix ownership
RUN chown -R root:root /var/lib/neo4j

################################################################################
# Expose ports
# npm
#
EXPOSE 80

# Expose ports
# neo4j
# see internals of docker-entrypoint.sh
EXPOSE 6001
EXPOSE 5001
EXPOSE 7474 7473

################################################################################
# Volumes
#
VOLUME /data
VOLUME /scratch

ENV PATH /scratch/:$PATH

################################################################################
# set CMD basic bash
#
CMD ["/bin/bash"]
