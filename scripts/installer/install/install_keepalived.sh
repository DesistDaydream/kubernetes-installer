#!/bin/bash
set -ue
set -o pipefail
#
source /root/downloads/variables.sh
# online 在线安装
function online(){
    yum install -y keepalived > /dev/null
}

# offline 离线安装
function offline(){
    echo -e "\033[32m $(hostname) 解压安装包并安装 keepalived 组件 \033[0m"
    tar -zxvf /root/downloads/keepalived-${KeepalivedVersion}.tar.gz -C /root/downloads > /dev/null
    yum localinstall -y /root/downloads/keepalived-${KeepalivedVersion}/* > /dev/null
}

# KeepalivedInstall 安装 keepalived
function KeepalivedInstall(){
    case ${online} in
    "yes")
        online
        ;;
    "no")
        offline
        ;;
    *)
        echo '请指定安装环境，在线或离线，修改 ${online} 变量即可'
        exit 1
        ;;
    esac
}

# KeepalivedConfig 配置 keepalived
function KeepalivedConfig(){
    source /root/downloads/config/keepalived_conf.sh
    source /root/downloads/config/keepalived_check_apiserver.sh
    source /root/downloads/config/keepalived_log_conf.sh
}

echo -e "\033[32m ====> $(hostname) 节点安装 keepalived \033[0m"
KeepalivedInstall

echo -e "\033[32m ====> $(hostname) 节点配置 keepalived \033[0m"
KeepalivedConfig

systemctl restart rsyslog && systemctl enable keepalived && systemctl restart keepalived
