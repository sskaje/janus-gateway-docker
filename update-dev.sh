#!/bin/sh

STUN_HOST=192.168.51.143
STUN_PORT=3478
ADMIN_KEY="supersecret"

if [[ "$(uname)" == "Darwin" ]]; then
  SED_IN_PLACE=(sed -i '')
else
  SED_IN_PLACE=(sed -i)
fi

# Enable STUN server
"${SED_IN_PLACE[@]}" -e "s#\#stun_server = \"stun.voip.eutelia.it\"#stun_server = \"${STUN_HOST}\"#g" config/janus.jcfg
"${SED_IN_PLACE[@]}" -e "s#\#stun_port = 3478#stun_port = ${STUN_PORT}#g" config/janus.jcfg

# Enable HTTP admin port
"${SED_IN_PLACE[@]}" -e 's#admin_http = false#admin_http = true#g' config/janus.transport.http.jcfg

# Enable streaming admin key
"${SED_IN_PLACE[@]}" -e "s#\#admin_key = \"supersecret\"#admin_key = \"${ADMIN_KEY}\"#g" config/janus.plugin.streaming.jcfg

# Update JavaScript files
echo "server = '/admin';" >> html/demos/admin.js
echo "server = '/janus';" >> html/demos/settings.js

echo "iceServers = [{urls: \"stun:${STUN_HOST}:${STUN_PORT}\"}];" >> html/demos/settings.js
