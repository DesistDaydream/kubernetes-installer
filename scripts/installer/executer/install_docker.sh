#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行安装 docker-ce 任务
function execute(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_docker.sh &
    done
    wait
    echo -e "\033[32m ====> 各节点 docker-ce 安装完成 \033[0m"
}

echo -e "\033[32m ====> 开始安装 docker-ce-${DockerVersion} \033[0m"
execute







