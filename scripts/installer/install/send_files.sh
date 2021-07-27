#!/bin/bash
set -ue
set -o pipefail
#
# online 在线安装
function online(){
    # 用于在使用 ssh 远程执行本地脚本时，在远程设备上加载环境变量所用
    sshpass -p ${Password} scp ${WorkDir}/variables/variables.sh root@${IP}:/root/downloads/variables.sh
    # 用于在使用 ssh 远程执行本地脚本时，引入其他脚本
    sshpass -p ${Password} scp ${WorkDir}/config/* root@${IP}:/root/downloads/config/
}

# offline 离线安装
function offline(){
    sshpass -p ${Password} scp \
    ${WorkDir}/package/kubeadm-let-ctl-${K8SVersion}.tar.gz \
    ${WorkDir}/package/docker-ce-${DockerVersion}.tar.gz \
    ${WorkDir}/package/k8s-images-${K8SVersion}.tar.gz \
    ${WorkDir}/variables/variables.sh \
    root@${IP}:/root/downloads
    sshpass -p ${Password} scp ${WorkDir}/config/* root@${IP}:/root/downloads/config/
    if [[ "${Masters[@]}" =~ "${node}" ]] && [[ "${#Masters[@]}" -gt "1" ]]; then
        sshpass -p ${Password} scp ./package/keepalived-${KeepalivedVersion}.tar.gz root@${IP}:/root/downloads
    fi
}

# SendFiles 分发部署所需离线安装包
function SendFiles(){
    HostName=$(hostname)
    sshpass -p ${Password} ssh -T root@${IP} '-o StrictHostKeyChecking=no' "mkdir -p /root/downloads/config && mkdir -p /root/kubernetes"
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

SendFiles
