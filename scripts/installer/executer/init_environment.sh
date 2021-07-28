#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行初始化环境任务
function execute(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/init_environment.sh &
    done
    wait
    echo -e "\033[32m ====> 各节点系统初始化完成 \033[0m"
}

echo -e "\033[32m ====> 初始化系统环境 \033[0m"
execute
