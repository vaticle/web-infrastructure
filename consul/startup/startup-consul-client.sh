#!/usr/bin/env bash

set -ex

ROOT_FOLDER=/mnt/consul-client
sudo mkdir -p $ROOT_FOLDER
sudo mkdir -p $ROOT_FOLDER/data

sleep 1m
gcloud compute scp --zone=europe-west2-b consul-server:/mnt/consul-server/consul-agent-ca-key.pem consul-agent-ca-key.pem >/dev/null 2>&1
gcloud compute scp --zone=europe-west2-b consul-server:/mnt/consul-server/consul-agent-ca.pem consul-agent-ca.pem >/dev/null 2>&1
gcloud compute scp --zone=europe-west2-b consul-server:/mnt/consul-server/encryption_key $ROOT_FOLDER/encryption_key >/dev/null 2>&1
consul tls cert create -client -dc uk
sudo mv consul-agent-ca.pem $ROOT_FOLDER/consul-agent-ca.pem
sudo mv consul-agent-ca-key.pem $ROOT_FOLDER/consul-agent-ca-key.pem
sudo mv uk-client-consul-0.pem $ROOT_FOLDER/uk-client-consul-0.pem
sudo mv uk-client-consul-0-key.pem $ROOT_FOLDER/uk-client-consul-0-key.pem

cat > $ROOT_FOLDER/consul.hcl << EOF
datacenter = "uk"
data_dir = "$ROOT_FOLDER/data"
encrypt = "$(cat $ROOT_FOLDER/encryption_key)"
ca_file = "$ROOT_FOLDER/consul-agent-ca.pem"
cert_file = "$ROOT_FOLDER/uk-client-consul-0.pem"
key_file = "$ROOT_FOLDER/uk-client-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
performance {
  raft_multiplier = 1
}
acl = {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}
retry_join = ["consul-server"]
EOF

cat > /etc/systemd/system/consul-client.service << EOF
[Unit]
Description=Consul Server
Wants=network.target
Requires=network-online.target
After=network-online.target
[Service]
Type=simple
ExecStart=sudo consul agent -config-dir=$ROOT_FOLDER
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul-client.service
sudo systemctl start consul-client.service
