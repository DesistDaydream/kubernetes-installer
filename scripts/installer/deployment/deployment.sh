#!/bin/bash
set -ue
set -o pipefail
#
# Install 部署 k8s 集群
function Deployment(){
    # 部署前环境检查
    # **未完待续**
    # source ${WorkDir}/check/check.sh

    # 部署节点
    source ${WorkDir}/executer/init_all_nodes.sh
    echo -e "\033[31m ============================================ \033[0m"
    echo -e "\033[31m =============所有节点已成功初始化============= \033[0m"
    echo -e "\033[31m ============================================ \033[0m"

    # 初始化集群
    source ${WorkDir}/init/init.sh
    echo -e "\033[31m ============================================ \033[0m"
    echo -e "\033[31m =============k8s集群已初始化完成============= \033[0m"
    echo -e "\033[31m ============================================ \033[0m"

    # 添加插件
    source ${WorkDir}/config/flannel.sh
    sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubectl apply -f /root/kubernetes/CNI/flannel.yaml"

    # 加入集群
    source ${WorkDir}/join/join.sh
    echo -e "\033[31m ============================================ \033[0m"
    echo -e "\033[31m =============！！请尽情使用吧！！============= \033[0m"
    echo -e "\033[31m ============================================ \033[0m"
}

Deployment