#!/bin/sh
#

docker build --target builder -t rst/janus-builder .
docker build -t rst/janus-gateway .


docker create --name temp-container rst/janus-builder

docker cp temp-container:/usr/local/etc/janus/. config
docker cp temp-container:/usr/local/share/janus/html/. html

docker rm temp-container
docker rmi rst/janus-builder


sed -i -e '~s#admin_http = false#admin_http = true#g' config/janus.transport.http.jcfg

echo "server = '/admin';" >> html/demos/admin.js
echo "server = '/janus';" >> html/demos/settings.js



