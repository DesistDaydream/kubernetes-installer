#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行安装 keepalived 任务
function execute(){
    for master in ${Masters[@]}; do
        IP=${master%%=*}
        if [[ "${#Masters[@]}" -gt "1" ]]; then
            sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_keepalived.sh &
        fi
    done
    wait
    echo -e "\033[32m ====> keepalived 安装完成 \033[0m"
}

echo -e "\033[32m ====> 判断是否需要安装 keepalived，若多 master 则安装 \033[0m"
execute
