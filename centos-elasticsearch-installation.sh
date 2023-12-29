#!/bin/bash

# Script Author: Pankaj Singh
# Github: pkstiyara
# Date: 14 December 2023

# Define variables
ES_VERSION="8.10.4"
prefix="/APPS/Elasticsearch"
tarball_dir="/opt/tarball"
ES_USER="elasticsearch-user"
ELASTIC_PASSWORD=""
ES_HOME="$prefix/elasticsearch-$ES_VERSION"

# Create directories
sudo mkdir -p "$prefix"
sudo mkdir -p "$tarball_dir"


# Create a dedicated user for Elasticsearch if not exists
if id "$ES_USER" &>/dev/null; then
    echo "User $ES_USER already exists."
else
    sudo adduser $ES_USER
fi


# Download Elasticsearch tarball
cd /opt/
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz.sha512
sha512sum -c elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz.sha512

# Extract Elasticsearch tarball
tar -xzf elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz -C "$prefix"
cd $ES_HOME || exit 1

# Change ownership of the Elasticsearch directory
sudo chown -R $ES_USER:$ES_USER "$prefix"

# Export ES_HOME
export ES_HOME="$ES_HOME"

# Start Elasticsearch
sudo -u $ES_USER bash -c "$ES_HOME/bin/elasticsearch" &

# Wait for Elasticsearch to start
sleep 60

# Extract credentials from the console output
ELASTIC_PASSWORD=$(grep -oP '(?<=Password for the elastic user \(reset with `bin/elasticsearch-reset-password -u elastic`\):\s+)[^\n]+' $ES_HOME/logs/*.log)

# Export ELASTIC_PASSWORD
export ELASTIC_PASSWORD="$ELASTIC_PASSWORD"

# Check if Elasticsearch is running
curl --cacert "$ES_HOME/config/certs/http_ca.crt" -u elastic:$ELASTIC_PASSWORD https://localhost:9200

# Print completion message
echo "Elasticsearch is installed and running. Accessible on https://localhost:9200."
echo "Elasticsearch credentials:"
echo "Username: elastic"
echo "Password: $ELASTIC_PASSWORD"
echo "Don't forget to configure other nodes to join this cluster."