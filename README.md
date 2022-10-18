# Docker Image for Namecoin

This is a docker image for [Namecoin](https://github.com/namecoin/namecoin-core) that builds from source.

Current version (tag): nc23.0
Builds and final image based on: Ubuntu 22.04

## Usage for docker-compose

Here is an example usage of this docker image:

  namecoin:
    image: mjmckinnon/namecoin
    container_name: namecoin
    command:
      -printtoconsole
      -debug=0
      -port=8334
      -rpcport=8335
      -rpcbind=127.0.0.1
      -rpcbind=namecoin
      -rpcallowip=127.0.0.1
      -rpcallowip=10.0.0.0/8
      -rpcallowip=172.16.0.0/16
    volumes:
      - /nfs/appstorage/namecoin:/data
    ports:
      - 8335:8335
      - 8334:8334
    restart: unless-stopped

