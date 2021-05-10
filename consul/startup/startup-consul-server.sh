#!/usr/bin/env bash

set -ex

ROOT_FOLDER=/mnt/consul-server
sudo mkdir -p $ROOT_FOLDER
sudo mkdir -p $ROOT_FOLDER/data

consul keygen > $ROOT_FOLDER/encryption_key
consul tls ca create
consul tls cert create -server -dc uk
sudo mv consul-agent-ca.pem $ROOT_FOLDER/consul-agent-ca.pem
sudo mv consul-agent-ca-key.pem $ROOT_FOLDER/consul-agent-ca-key.pem
sudo mv uk-server-consul-0.pem $ROOT_FOLDER/uk-server-consul-0.pem
sudo mv uk-server-consul-0-key.pem $ROOT_FOLDER/uk-server-consul-0-key.pem

cat > $ROOT_FOLDER/consul.hcl << EOF
datacenter = "uk"
data_dir = "$ROOT_FOLDER/data"
encrypt = "$(cat $ROOT_FOLDER/encryption_key)"
ca_file = "$ROOT_FOLDER/consul-agent-ca.pem"
cert_file = "$ROOT_FOLDER/uk-server-consul-0.pem"
key_file = "$ROOT_FOLDER/uk-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
acl = {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}
performance {
  raft_multiplier = 1
}
EOF

cat > $ROOT_FOLDER/server.hcl << EOF
server = true
bootstrap_expect = 1
client_addr = "0.0.0.0"
ui = true
EOF

cat > /usr/bin/format-consul-server-additional.sh << EOF
#!/usr/bin/env bash
FS_TYPE=$(blkid -o value -s TYPE /dev/disk/by-id/google-consul-server-additional)
[ -z "$FS_TYPE" ] && sudo mkfs.ext4 /dev/disk/by-id/google-consul-server-additional || true
EOF

cat > /etc/systemd/system/format-consul-server-additional.service << EOF
[Unit]
Description=Format consul server additional disk
After=/dev/disk/by-id/google-consul-server-additional
Requires=/dev/disk/by-id/google-consul-server-additional
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /usr/bin/format-consul-server-additional.sh
EOF

MOUNT_SCRIPT=$(systemd-escape -p --suffix=mount $ROOT_FOLDER/data)
cat > /etc/systemd/system/$MOUNT_SCRIPT << EOF
[Unit]
Description=Mount consul server additional disk
Requires=format-consul-server-additional.service
After=format-consul-server-additional.service
[Mount]
What=/dev/disk/by-id/google-consul-server-additional
Where=$ROOT_FOLDER/data
Type=ext4
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/consul-server.service << EOF
[Unit]
Description=Consul Server
Wants=network.target
Requires=network-online.target $MOUNT_SCRIPT
After=network-online.target $MOUNT_SCRIPT
[Service]
Type=simple
ExecStart=sudo consul agent -config-dir=$ROOT_FOLDER
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable format-consul-server-additional.service
sudo systemctl enable $MOUNT_SCRIPT
sudo systemctl enable consul-server.service
sudo systemctl start consul-server.service

sleep 30s
export CONSUL_CACERT=$ROOT_FOLDER/consul-agent-ca.pem
export CONSUL_CLIENT_CERT=$ROOT_FOLDER/uk-server-consul-0.pem
export CONSUL_CLIENT_KEY=$ROOT_FOLDER/uk-server-consul-0-key.pem
consul acl bootstrap | awk '/SecretID/ {print $2}' > $ROOT_FOLDER/token
