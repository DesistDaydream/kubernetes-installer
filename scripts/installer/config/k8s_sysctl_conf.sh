#!/bin/bash
set -ue
set -o pipefail
#
cat > /etc/sysctl.d/k8s-sysctl.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 10
vm.max_map_count = 262144
EOF
sysctl -p /etc/sysctl.d/* > /dev/null