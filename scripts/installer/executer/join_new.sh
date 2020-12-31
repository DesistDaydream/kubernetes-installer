#!/bin/bash
set -ue
set -o pipefail
#
# addNewNodeInfoToVariablesFile 为 variables.sh 文件添加新增的 node 信息
function addNewNodeInfoToVariablesFile(){
    for node in ${NewNodes[@]}; do
        if ! grep "${node%%=*}=${node##*=}" ${WorkDir}/variables/variables.sh; then
            sed -i "/^Nodes/a'${node%%=*}=${node##*=}'" ${WorkDir}/variables/variables.sh
        fi
    done
}
WorkDir=$(pwd)
addNewNodeInfoToVariablesFile
source ${WorkDir}/variables/variables.sh
if [[ ${#Nodes[@]} -gt "0" ]]; then
    AllNodes=("${Masters[@]}" "${Nodes[@]}")
else
    AllNodes=("${Masters[@]}")
fi

# checkIP 检查用户输入的IP是否合法
function checkIP(){   
    VALID_CHECK=$(echo $IP|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    if echo ${IP} | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" > /dev/null; then
        if [ ${VALID_CHECK:-no} != "yes" ]; then
            echo "IP $IP 不可用!"; exit 1
        fi
    else
        echo "IP 格式错误，请重新输入!"; exit 1
    fi
}

# confirmNew 确认新增节点信息,并检查命令行输入的 IP 格式
function confirmNew(){    
    for newnode in ${NewNodes[@]}; do
        IP=${newnode%%=*}
        echo -e "\033[31m ${newnode%%=*} ${newnode##*=} \033[0m"
        checkIP      
    done
    echo "root密码为：${Password},错了可没法执行呦~"
        read -p "请确认以上信息是否要新增的节点(yes/no):" Confirm
    if [[ ${Confirm} != "yes" ]]; then
        exit 1
    fi
}

# genHosts 为所有节点重新配置 hosts 文件
function genHosts(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        HostName=${node##*=}
        # 为所有节点重新分发信息文件
        source ${WorkDir}/install/send_files.sh
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/gen_hosts.sh
    done
    wait
}

# check 通过 kube-proxy 的状态检查节点是否已经在集群中
function Check(){
    sshpass -p ${Password} ssh -T root@${IP} "curl --silent --max-time 2 http://127.0.0.1:10249/healthz"
}

# NodeJoinCluster 让所有 node 加入集群
function JoinNew(){
    for node in ${NewNodes[@]}; do        
        IP=${node%%=*}
        HostName=${node##*=}        
        case $(Check) in
        "ok")
            echo -e "\033[31m ${node##*=} 节点已加入集群，不用再次加入 \033[0m"
            ;;
        *)
            source ${WorkDir}/join/join_new.sh
            ;;
        esac        
    done
    wait
}

confirmNew

echo -e "\033[32m ====> 重设所有节点的 hosts 文件，添加新节点解析 \033[0m"
genHosts

echo -e "\033[32m ====> 开始为集群增加 ${NewNodes[@]##*=} 节点 \033[0m"
JoinNew

