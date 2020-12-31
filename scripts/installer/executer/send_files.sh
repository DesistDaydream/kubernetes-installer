#!/bin/bash
set -ue
set -o pipefail
#
# execute 开始执行任务
function execute(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        source ${WorkDir}/install/send_files.sh &
    done
    wait
    echo -e "\033[32m ====> 安装包已分发到所有节点 \033[0m"
}

echo -e "\033[32m ====> 分发安装包 \033[0m"
execute