#!/bin/bash
set -ue
set -o pipefail
#
source ${WorkDir}/variables/variables.sh
# 初始化系统

# SendFile 发送所需文件
function SendFile(){
    for dr in ${DR[@]}; do
        IP=${dr%%=*}
        source ${WorkDir}/install/send_files.sh &
    done
    wait
    echo -e "\033[32m ====> 安装包已分发到所有节点 \033[0m"
}

# keepalivedInstall 安装 keepalived
function KeepalivedInstall(){
    for dr in ${DR[@]}; do
        IP=${dr%%=*}
        sshpass -p ${Password} ssh -T root@${IP} < ${WorkDir}/install/install_keepalived.sh &
    done
    wait
    echo -e "\033[32m ====> keepalived 安装完成 \033[0m"
}

echo -e "\033[32m ====> 分发安装包 \033[0m"
SendFile

echo -e "\033[32m ====> 开始安装 keepalived \033[0m"
KeepalivedInstall
