#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行安装 kubernetes 任务
function execute(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_kubernetes.sh > /dev/null &
    done
    wait

    # 拷贝具有100年证书的特殊 kubeadm 到所有节点
    echo -e "\033[32m ====> 拷贝100年证书的 kubeadm 到各节点！请稍后.... \033[0m"
    chmod 755 ${WorkDir}/package/kubeadm
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} scp ${WorkDir}/package/kubeadm root@${IP}:/usr/bin/kubeadm &
    done
    wait

    echo -e "\033[32m ====> 各节点 kubernetes 工具三件套 安装完成 \033[0m"
}

echo -e "\033[32m ====> 开始安装 kubernetes 工具三件套 \033[0m"
execute



