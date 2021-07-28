#!/bin/bash
set -ue
set -o pipefail
#
# execute 执行生成 hosts 文件任务
function execute(){
    for node in ${AllNodes[@]}; do
        IP=${node%%=*}
        HostName=${node##*=}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/gen_hosts.sh &
        sshpass -p ${Password} ssh -T root@${IP} hostnamectl set-hostname ${HostName} &
    done
    wait
    echo -e "\033[32m ====> hosts 文件已生成 \033[0m"
}

echo -e "\033[32m ====> 生成 hosts 文件 \033[0m"
execute