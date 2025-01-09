#!/bin/sh
#

docker build --target builder -t rst/janus-builder .
docker build -t rst/janus-gateway .


docker create --name temp-container rst/janus-builder

docker cp temp-container:/usr/local/etc/janus/. config
docker cp temp-container:/usr/local/share/janus/. html

docker rm temp-container
docker rmi rst/janus-builder



