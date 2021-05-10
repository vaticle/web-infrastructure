#!/usr/bin/env bash

set -ex

ROOT_FOLDER=/mnt/consul-client
sudo mkdir -p $ROOT_FOLDER
sudo mkdir -p $ROOT_FOLDER/data

sleep 1m
gcloud compute scp --zone=europe-west2-b consul-server:/mnt/consul-server/consul-agent-ca.pem consul-agent-ca.pem >/dev/null 2>&1
gcloud compute scp --zone=europe-west2-b consul-server:/mnt/consul-server/consul-agent-ca-key.pem consul-agent-ca-key.pem >/dev/null 2>&1
consul tls cert create -client -dc uk
sudo mv consul-agent-ca.pem $ROOT_FOLDER/consul-agent-ca.pem
sudo mv consul-agent-ca-key.pem $ROOT_FOLDER/consul-agent-ca-key.pem
sudo mv uk-client-consul-0.pem $ROOT_FOLDER/uk-client-consul-0.pem
sudo mv uk-client-consul-0-key.pem $ROOT_FOLDER/uk-client-consul-0-key.pem
