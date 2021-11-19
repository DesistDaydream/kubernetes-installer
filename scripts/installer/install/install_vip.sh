#!/bin/bash
set -ue
set -o pipefail
#
source /root/downloads/variables.sh
# online 在线安装
function online(){
    mkdir -p /etc/kubernetes/manifests
    docker run --rm --net host docker.io/plndr/kube-vip:${kubeVIP} \
    manifest pod \
    --interface ${InterfaceName} \
    --vip $VIP \
    --controlplane \
    --services \
    --arp \
    --leaderElection | tee  /etc/kubernetes/manifests/kube-vip.yaml
}

# offline 离线安装
function offline(){
    echo -e "\033[32m $(hostname) 生成 kube-vip 的 Manifest 文件 \033[0m"
    mkdir -p /etc/kubernetes/manifests
    cat > /etc/kubernetes/manifests/kube-vip.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: kube-vip
  namespace: kube-system
spec:
  containers:
  - args:
    - manager
    env:
    - name: vip_arp
      value: "true"
    - name: vip_interface
      value: ${InterfaceName}
    - name: port
      value: "6443"
    - name: vip_cidr
      value: "32"
    - name: cp_enable
      value: "true"
    - name: cp_namespace
      value: kube-system
    - name: vip_ddns
      value: "false"
    - name: svc_enable
      value: "true"
    - name: vip_leaderelection
      value: "true"
    - name: vip_leaseduration
      value: "5"
    - name: vip_renewdeadline
      value: "3"
    - name: vip_retryperiod
      value: "1"
    - name: vip_address
      value: ${VIP}
    image: plndr/kube-vip:v0.3.7
    name: kube-vip
    resources: {}
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - NET_RAW
        - SYS_TIME
    volumeMounts:
    - mountPath: /etc/kubernetes/admin.conf
      name: kubeconfig
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/admin.conf
    name: kubeconfig
status: {}
EOF
}

# VIPInstall 安装 VIP
function VIPInstall(){
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

echo -e "\033[32m ====> $(hostname) 节点安装 VIP \033[0m"
VIPInstall