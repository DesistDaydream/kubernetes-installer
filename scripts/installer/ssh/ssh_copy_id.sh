#!/bin/bash
set -ue
set -o pipefail
#
# SSHCopyID 配置 ssh 免密
function SSHCopyID(){
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    for IP in ${AllNodes[@]%%=*}; do
    expect
    # 未完待续！！！
    done
}

echo -e "\033[32m ====> 开始配置免密登录信息 \033[0m"
SSHCopyID
