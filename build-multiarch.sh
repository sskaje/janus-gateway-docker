#!/bin/sh
#

DOCKER_BUILDKIT=1 docker buildx build --platform linux/amd64,linux/arm64 --target builder  -t rst/janus-builder .
DOCKER_BUILDKIT=1 docker buildx build --platform linux/amd64,linux/arm64 -t rst/janus-gateway .
