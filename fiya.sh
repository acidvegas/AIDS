#!/bin/sh

# Configuration
MAIN="brandon.hidden"
DNS_SERVER="pi.hidden"
ES_NODES="nodes.hidden"

# Configuration (Ports)
PORT_DNS=53
PORT_SSH=2023
PORT_ES_HTTP=9200
PORT_ES_TRANS=9300
PORT_KIBANA=5601

resolve_ip() {
    nslookup $1 | awk '/^Address: / { print $2 }' | shuf -n 1
}

MAIN=$(resolve_ip $MAIN)
DNS_SERVER=$(resolve_ip $DNS_SERVER)
ES_NODES=$(echo $ES_NODES | xargs -n1 resolve_ip)
LOCAL_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1)

ufw reset
ufw default deny incoming
ufw default allow outgoing

ufw allow from $DNS_SERVER to any port $PORT_SSH proto tcp
ufw allow from $MAIN to any port $PORT_SSH proto tcp
ufw allow from $MAIN to any port $PORT_ES_HTTP proto tcp

# Allow Elasticsearch transport communication within the nodes
for node in $ES_NODES; do
    if [ $node != $LOCAL_IP ]; then
        ufw allow from $node to any port $PORT_ES_TRANS proto tcp
    fi
done

# Allow Kibana access from main
#ufw allow from $MAIN to any port $PORT_KIBANA proto tcp

sudo ufw enable
sudo ufw reload