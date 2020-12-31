#!/bin/bash
set -ue
set -o pipefail
#
cat > /etc/sysctl.d/docker.conf << EOF
net.ipv4.ip_forward = 1
EOF