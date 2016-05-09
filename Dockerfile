FROM node:wheezy

# Install Neo4j
WORKDIR /root
RUN wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
RUN echo 'deb http://debian.neo4j.org/repo stable/' >/tmp/neo4j.list
RUN mv /tmp/neo4j.list /etc/apt/sources.list.d
RUN apt-get update
RUN apt-cache madison neo4j
RUN apt-get install -y neo4j=2.3.3

# Create app directory with source-code
RUN mkdir -p /usr/src/app
COPY .       /usr/src/app
WORKDIR      /usr/src/app

# Install app dependencies
RUN npm install

# Expose ports
EXPOSE 80 7474

# Expose neo4j data directory
# TODO

# Start neo4j and node servers
CMD [ "/bin/bash", "entrypoint.sh" ]
