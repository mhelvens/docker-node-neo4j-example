FROM node:wheezy

# update
RUN apt-get update --quiet --quiet \
    && apt-get install --quiet --quiet --no-install-recommends lsof \
    && rm -rf /var/lib/apt/lists/*

# Create app directory with source-code
RUN mkdir -p /usr/src/app
COPY .       /usr/src/app
WORKDIR      /usr/src/app

# Install app dependencies
RUN npm install

# Install Neo4j
#WORKDIR /root
#RUN wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
#RUN echo 'deb http://debian.neo4j.org/repo stable/' >/tmp/neo4j.list
#RUN mv /tmp/neo4j.list /etc/apt/sources.list.d
#RUN apt-get update
#RUN apt-cache madison neo4j
#RUN apt-get install -y neo4j=2.3.3

WORKDIR /root
ENV NEO4J_VERSION 2.3.3
ENV NEO4J_EDITION community
ENV NEO4J_DOWNLOAD_SHA256 01559c55055516a42ee2dd100137b6b55d63f02959a3c6c6db7a152e045828d9
ENV NEO4J_DOWNLOAD_ROOT http://dist.neo4j.org
ENV NEO4J_TARBALL neo4j-$NEO4J_EDITION-$NEO4J_VERSION-unix.tar.gz
ENV NEO4J_URI $NEO4J_DOWNLOAD_ROOT/$NEO4J_TARBALL

RUN curl --fail --silent --show-error --location --output neo4j.tar.gz $NEO4J_URI \
    && echo "$NEO4J_DOWNLOAD_SHA256 neo4j.tar.gz" | sha256sum --check --quiet - \
    && tar --extract --file neo4j.tar.gz --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm neo4j.tar.gz

WORKDIR /var/lib/neo4j

RUN mv data /data \
    && ln --symbolic /data

VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Expose ports
EXPOSE 80 
EXPOSE 7474

# Start neo4j and node servers
CMD [ "/bin/bash", "entrypoint.sh", "docker-entrypoint.sh neo4j" ]
