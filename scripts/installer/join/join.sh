#!/bin/bash
set -ue
set -o pipefail
#
source ./variables/variables.sh
# check 检查节点是否已经在集群中
function Check(){
    sshpass -p ${Password} ssh -T root@${IP} "curl --silent --max-time 2 http://127.0.0.1:10249/healthz"
}

# genJoinCMD 生成加入集群命令
function GenJoinCMD(){
    MasterJoinKey=$(sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubeadm init phase upload-certs --upload-certs  2> /dev/null | awk 'END {print}'")
    MasterJoinCMD=$(sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubeadm token create --ttl=2h --certificate-key=${MasterJoinKey} --print-join-command  2> /dev/null")
    echo -e "\033[34m 控制平面加入集群指令：${MasterJoinCMD} \033[0m"

    NodeJoinCMD=$(sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "kubeadm token create --ttl=2h --print-join-command" 2> /dev/null)
    echo -e "\033[34m 工作负载平面加入集群指令：${NodeJoinCMD} \033[0m"
}

# MasterJoinCluster 让所有 master 加入集群
function MasterJoinCluster(){
    for master in "${Masters[@]:1}"; do
        IP=${master%%=*}

        case $(Check) in
        "ok")
            echo -e "\033[31m ${master##*=} 节点已加入集群，不用再次加入 \033[0m"
            ;;
        *)
            sshpass -p ${Password} ssh -T root@${IP} "${MasterJoinCMD}"
            # 配置 kubectl 命令
            sshpass -p ${Password} ssh -T root@${IP} "
            mkdir -p $HOME/.kube
            \cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
            echo 'source <(kubectl completion bash)' >> ~/.bashrc
            echo 'source <(kubeadm completion bash)' >> ~/.bashrc
            "
            ;;
        esac
    done
}

# NodeJoinCluster 让所有 node 加入集群
function NodeJoinCluster(){
    for node in ${Nodes[@]}; do
        IP=${node%%=*}

        case $(Check) in
        "ok")
            echo -e "\033[31m ${node##*=} 节点已加入集群，不用再次加入 \033[0m"
            ;;
        *)
            sshpass -p ${Password} ssh -T root@${IP} "${NodeJoinCMD}" &
            ;;
        esac
    done
    wait
}

# 生成加入集群所需命令
GenJoinCMD

# 加入其他 master 节点
if [[ "${#Masters[@]}" -gt "1" ]];then
    echo -e "\033[32m ====> 让其余 master 节点加入集群 \033[0m"
    MasterJoinCluster
fi

# 加入其他 node 节点
if [[ ${#Nodes[@]} -gt "0" ]]; then
    echo -e "\033[32m ====> 让 node 节点加入集群 \033[0m"
    NodeJoinCluster
fi