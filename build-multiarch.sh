#!/bin/sh
#

docker buildx build --platform linux/amd64,linux/arm64 --target builder  -t rst/janus-builder .
docker buildx build --platform linux/amd64,linux/arm64 -t rst/janus-gateway .

docker create --name temp-container rst/janus-builder

docker cp temp-container:/usr/local/etc/janus/. config
docker cp temp-container:/usr/local/share/janus/html/. html

docker rm temp-container
# docker rmi rst/janus-builder


