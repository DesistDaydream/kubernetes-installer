#!/bin/bash
set -ue
set -o pipefail
#
# check 检查集群状态，不要重复初始化
function Check(){
    curl --silent --max-time 2 --insecure https://${Masters[0]%%=*}:6443/healthz
}

# Initcluster 在其中一个 master 节点上初始化 k8s 集群
function InitCluster(){
    source ${WorkDir}/config/kubeadm_config.sh
    sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubeadm init --config=/root/kubernetes/kubeadm-config.yaml --upload-certs"
    # 配置 kubectl 命令
    sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "
    mkdir -p $HOME/.kube
    \cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
    echo 'source <(kubectl completion bash)' >> ~/.bashrc
    echo 'source <(kubeadm completion bash)' >> ~/.bashrc
    "
}

echo -e "\033[32m ====> 初始化 kubernetes 集群 \033[0m"
if [[ $(Check) != "ok" ]]; then
    InitCluster
else
    echo "master 节点初始化错误，apiserver 已存在，请使用干净的操作系统或执行 bash main.sh -p XX --reset 命令清理环境"
    exit 1
fi
