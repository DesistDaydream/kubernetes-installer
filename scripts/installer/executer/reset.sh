#!/bin/bash
set -ue
set -o pipefail
#
# Reset 逐一清理集群中各节点
function Reset(){
    echo -e "\033[31m ====> 先清理 Node 节点 \033[0m"
    for node in ${Nodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} ssh -o StrictHostKeyChecking=no -T root@${IP}  < ${WorkDir}/reset/reset.sh
    done
    wait

    echo -e "\033[31m ====> 再清理 Master 节点 \033[0m"
    for master in ${Masters[@]}; do
        IP=${master%%=*}
        sshpass -p ${Password} ssh -o StrictHostKeyChecking=no -T root@${IP}  < ${WorkDir}/reset/reset.sh
    done
    wait
}

echo -e "\033[31m ====> 逐一清理集群中各节点 \033[0m"
Reset