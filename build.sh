#!/bin/sh
#

docker build --target builder -t rst/janus-builder .
docker build -t rst/janus-gateway .


