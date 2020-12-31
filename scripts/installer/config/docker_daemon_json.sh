#!/bin/bash
set -ue
set -o pipefail
#
if [[ `grep "iptables" /usr/lib/systemd/system/docker.service` != "0" ]]; then
    sed -i "14i ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT" /usr/lib/systemd/system/docker.service
fi

mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://ac1rmo5p.mirror.aliyuncs.com"],
  "insecure-registries": [${InsecureRegistries}],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "default-address-pools" : [
    {"base" : "${DefaultAddressPools}","size" : 24}
  ],
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "5m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
  "overlay2.override_kernel_check=true"
  ]
}
EOF