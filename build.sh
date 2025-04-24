#!/bin/sh
#

DOCKER_BUILDKIT=1 docker build --target builder -t rst/janus-builder .
DOCKER_BUILDKIT=1 docker build -t rst/janus-gateway .


