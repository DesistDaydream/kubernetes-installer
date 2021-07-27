#!/bin/bash
set -ue
set -o pipefail
#
source /root/downloads/variables.sh
HostName=$(hostname)

# online 在线安装
function online(){
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

    yum install -y kubelet-${K8SVersion#v} kubeadm-${K8SVersion#v} kubectl-${K8SVersion#v} > /dev/null
}
# offline 离线安装
function offline(){
    echo -e "\033[32m ${HostName} 解压安装包并安装 kubernetes 组件 \033[0m"
    mkdir -p /opt/cni/bin
    tar -zxvf /root/downloads/cni-plugins-linux-amd64-${CNIPluginVersion}.tgz -C /opt/cni/bin
    chmod +x /root/downloads/{kubeadm,kubelet,kubectl}
    cp /root/downloads/{kubeadm,kubectl,kubelet} /usr/bin/
    cp /root/downloads/kubelet.service /usr/lib/systemd/system/kubelet.service
    mkdir -p /usr/lib/systemd/system/kubelet.service.d
    cp /root/downloads/10-kubeadm.conf /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

    echo -e "\033[32m ${HostName} 正在解压镜像，请稍后.....Zzzz，请冲杯咖啡休息一下，\033[0m\033[31m不要强行退出哦！\033[0m"
    if [[ ! -f '/root/downloads/k8s-images.tar' ]]; then gzip -d /root/downloads/k8s-images-${K8SVersion}.tar.gz; fi
    docker load -i /root/downloads/k8s-images-${K8SVersion}.tar > /dev/null
}

# KubernetesInstall 安装 kubeadm kubectl kubelet
function KubernetesInstall(){
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
    systemctl enable kubelet
}

# KubernetesConfig 配置 kubernetes 运行环境和参数
function KubernetesConfig(){
    source /root/downloads/config/k8s_sysctl_conf.sh
}

echo -e "\033[32m ====> ${HostName} 安装 k8s 三件套 \033[0m"
KubernetesInstall

echo -e "\033[32m ====> ${HostName} 配置 k8s 运行环境 \033[0m"
KubernetesConfig
