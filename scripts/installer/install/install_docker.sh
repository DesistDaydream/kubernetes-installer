#!/bin/bash
set -ue
set -o pipefail
#
source /root/downloads/variables.sh
# online 在线安装
function online(){
    yum install -y yum-utils device-mapper-persistent-data lvm2 > /dev/null
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > /dev/null
    yum install -y docker-ce-${DockerVersion} docker-ce-cli-${DockerVersion} > /dev/null
}

# offline 离线安装
function offline(){
    tar -zxvf /root/downloads/docker-ce-${DockerVersion}.tar.gz -C /root/downloads > /dev/null
    yum localinstall -y /root/downloads/docker-ce-${DockerVersion}/* > /dev/null
}

# DockerInstall 安装 docker
function DockerInstall(){
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

# DockerConfig 配置 docker 运行时环境以及参数
function DockerConfig(){
    source /root/downloads/config/docker_daemon_json.sh
    source /root/downloads/config/docker_sysctl_conf.sh
}

HostName=$(hostname)
echo -e "\033[32m ====> ${HostName} 安装 docker \033[0m"
DockerInstall

echo -e "\033[32m ====> ${HostName} 配置 docker 运行环境 \033[0m"
DockerConfig

systemctl daemon-reload
systemctl restart docker && systemctl enable docker