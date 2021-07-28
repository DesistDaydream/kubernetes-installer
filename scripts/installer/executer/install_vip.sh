#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行安装 vip 任务
function execute(){
    for master in ${Masters[@]}; do
        IP=${master%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_vip.sh &
    done
    wait
    echo -e "\033[32m ====> vip 安装完成 \033[0m"
}

echo -e "\033[32m ====> 安装 vip \033[0m"
execute
