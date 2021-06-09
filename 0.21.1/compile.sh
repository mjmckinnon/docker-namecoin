#!/bin/sh

# Build the image (which will compile everything we need)
docker build -t namecoind:0.21.1 .

# Create the container for dist-file extraction
docker create --name namecoin-extract namecoind:0.21.1

# Copy the files out of the container
mkdir -p ./dist-files
docker cp namecoin-extract:/dist-files ./dist-files

# Remove the container
docker rm namecoin-extract
