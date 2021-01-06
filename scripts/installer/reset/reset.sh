#!/bin/bash
set -ue
set -o pipefail
#
HostName=$(hostname)
echo -e "\033[32m ====> ${HostName} 正在清理环境 \033[0m"
kubeadm reset -f
rm -rf ~/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd
iptables -F
iptables -X
iptables -F -t nat
iptables -X -t nat
ipvsadm --clear
if [[ $(ip link show | grep kube-ipvs0) ]];then
	ip link del kube-ipvs0
fi