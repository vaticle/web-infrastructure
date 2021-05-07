#!/usr/bin/env bash

set -ex

ROOT_FOLDER=/mnt/consul
sudo mkdir -p $ROOT_FOLDER
sudo mkdir -p $ROOT_FOLDER/data

cat > $ROOT_FOLDER/config.hcl << EOF
EOF

cat > /usr/bin/format-consul-additional.sh << EOF
#!/usr/bin/env bash
FS_TYPE=$(blkid -o value -s TYPE /dev/disk/by-id/google-consul-additional)
[ -z "$FS_TYPE" ] && sudo mkfs.ext4 /dev/disk/by-id/google-consul-additional || true
EOF

cat > /etc/systemd/system/format-consul-additional.service << EOF
[Unit]
Description=Format consul additional disk
After=/dev/disk/by-id/google-consul-additional
Requires=/dev/disk/by-id/google-consul-additional
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /usr/bin/format-consul-additional.sh
EOF

MOUNT_SCRIPT=$(systemd-escape -p --suffix=mount $ROOT_FOLDER/data)
cat > /etc/systemd/system/$MOUNT_SCRIPT << EOF
[Unit]
Description=Mount consul additional disk
Requires=format-consul-additional.service
After=format-consul-additional.service
[Mount]
What=/dev/disk/by-id/google-consul-additional
Where=$ROOT_FOLDER/data
Type=ext4
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/consul.service << EOF
[Unit]
Description=Nomad Server
Wants=network.target
Requires=network-online.target $MOUNT_SCRIPT
After=network-online.target $MOUNT_SCRIPT
[Service]
Type=simple
ExecStart=sudo consul server -config=$ROOT_FOLDER/config.hcl
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable format-consul-additional.service
sudo systemctl enable $MOUNT_SCRIPT
sudo systemctl enable consul.service
sudo systemctl start consul.service
