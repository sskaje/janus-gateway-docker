#!/bin/sh


docker create --name temp-container rst/janus-builder

docker cp temp-container:/usr/local/etc/janus/. config
docker cp temp-container:/usr/local/share/janus/html/. html
docker cp temp-container:/tmp/copy/docs/. html/docs

docker rm temp-container
# docker rmi rst/janus-builder

