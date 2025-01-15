#!/bin/sh
#

docker buildx build --platform linux/amd64,linux/arm64 --target builder  -t rst/janus-builder .
docker buildx build --platform linux/amd64,linux/arm64 -t rst/janus-gateway .
