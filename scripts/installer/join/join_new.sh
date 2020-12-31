#!/bin/bash
set -ue
set -o pipefail
#
# initNewNode 初始化新增的节点
function initNewNode(){
    # 设置主机名
    sshpass -p ${Password} ssh -T root@${IP} hostnamectl set-hostname ${HostName}

    # 初始化环境
    sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/init_environment.sh

    # 安装 docker-ce
    sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_docker.sh

    # 安装kubeadm kubectl kubelet
    sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_kubernetes.sh
    # sshpass -p ${Password} scp ${WorkDir}/rpm/kubeadm root@${IP}:/usr/bin/kubeadm
}

# genJoinCMD 生成加入集群命令
function GenJoinCMD(){
    NodeJoinCMD=$(sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubeadm token create --ttl=2h --print-join-command" 2> /dev/null)
    echo -e "\033[34m 工作负载平面加入集群指令：${NodeJoinCMD} \033[0m"
}

initNewNode

GenJoinCMD

sshpass -p ${Password} ssh -T root@${IP} "${NodeJoinCMD}"
