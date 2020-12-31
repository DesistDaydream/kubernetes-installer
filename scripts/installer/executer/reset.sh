#!/bin/bash
set -ue
set -o pipefail
#
# Reset 逐一清理集群中各节点
function Reset(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/reset/reset.sh
    done
    wait
}

echo -e "\033[31m ====> 逐一清理集群中各节点 \033[0m"
Reset