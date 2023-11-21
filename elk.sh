#!/bin/sh
CLUSTER_NAME="beehive"
NODE_NAME="node-1"
VERSION=8.11.1

export ES_HOME=$HOME/elasticsearch
#export ELASTIC_PASSWORD="your_password"

setup_elastic() {
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION-linux-x86_64.tar.gz
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION-linux-x86_64.tar.gz.sha512
    shasum -a 512 -c elasticsearch-$VERSION-linux-x86_64.tar.gz.sha512 
    tar -xzf elasticsearch-$VERSION-linux-x86_64.tar.gz
    mv elasticsearch-$VERSION elasticsearch
    rm elasticsearch-$VERSION-linux-x86_64.tar.gz
    rm elasticsearch-$VERSION-linux-x86_64.tar.gz.sha512

    sed -i 's/^#cluster.name: .*/cluster.name: $CLUSER_NAME/' $HOME/elasticsearch/config/elasticsearch.yml
    sed -i 's/^#node.name: .*/node.name: $NODE_NAME/' $HOME/elasticsearch/config/elasticsearch.yml
    sed -i 's/^#bootstrap.memory_lock: true/bootstrap.memory_lock: true/' $HOME/elasticsearch/config/elasticsearch.yml
    #network.host: 192.168.0.1
    #http.port: 9200
    $HOME/elasticsearch/bin/elasticsearch -d -p pid
}

# Create enrollment token (on the master node)
$HOME/elasticsearch/bin/elasticsearch-create-enrollment-token -s node

# Start the node (on the node)
$HOME/elasticsearch/bin/elasticsearch --enrollment-token <enrollment-token>





setup_kibana() {
    # Download kibana
    curl -O https://artifacts.elastic.co/downloads/kibana/kibana-$VERSION-linux-x86_64.tar.gz
    curl https://artifacts.elastic.co/downloads/kibana/kibana-$VERSION-linux-x86_64.tar.gz.sha512 | shasum -a 512 -c - 
    tar -xzf kibana-$VERSION-linux-x86_64.tar.gz
    mv kibana-$VERSION kibana
    rm kibana-$VERSION-linux-x86_64.tar.gz
    rm kibana-$VERSION-linux-x86_64.tar.gz.sha512
}