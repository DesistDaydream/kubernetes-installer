#!/bin/bash
set -ue
set -o pipefail
#
# DeploymentNodes 逐一部署集群中的所有节点，为初始化集群做准备
function InitNodes(){
    # 分发文件
    source ${WorkDir}/executer/send_files.sh

    # 配置主机名与hosts文件
    source ${WorkDir}/executer/gen_hosts.sh

    # 初始化环境
    source ${WorkDir}/executer/init_environment.sh

    # 安装 docker-ce
    source ${WorkDir}/executer/install_docker.sh

    # 安装kubeadm kubectl kubelet
    source ${WorkDir}/executer/install_kubernetes.sh

    # 如果是 master 节点，则安装并配置 vip。
    source ${WorkDir}/executer/install_vip.sh
}

echo -e "\033[31m ====> 逐一部署集群中各节点 \033[0m"
InitNodes