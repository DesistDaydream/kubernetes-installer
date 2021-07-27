#!/bin/bash
set -ue
set -o pipefail
#
# GenCertSANS 生成 API Server 证书
# 通过 sed 在 certSANs字段下面添加内容
function GenCertSANS(){
    for node in ${Masters[@]}; do
        IP=${node%%=*}
        HostName=${node##*=}
        sed -i "/certSANs/a\ \ - ${IP}" /tmp/kubeadm-config.yaml
        sed -i "/certSANs/a\ \ - ${HostName}" /tmp/kubeadm-config.yaml
    done
    sed -i "/certSANs/a\ \ - ${VIP}" /tmp/kubeadm-config.yaml
    sed -i "/certSANs/a\ \ - ${Domain}" /tmp/kubeadm-config.yaml
    # sed -i "/certSANs/a\ \ - kubernetes.default.svc.${DnsDomain}" /tmp/kubeadm-config.yaml
    # sed -i "/certSANs/a\ \ - kubernetes.default.svc" /tmp/kubeadm-config.yaml
    # sed -i "/certSANs/a\ \ - kubernetes.default" /tmp/kubeadm-config.yaml
    # sed -i "/certSANs/a\ \ - kubernetes" /tmp/kubeadm-config.yaml
    sed -i "/certSANs/a\ \ - 127.0.0.1" /tmp/kubeadm-config.yaml
    sed -i "/certSANs/a\ \ - localhost" /tmp/kubeadm-config.yaml
}

# SendKubeadmconfig 分发 kubeadm-config.yaml 文件
function SendKubeadmconfig(){
    cat > /tmp/kubeadm-config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  ttl: 0s
  usages:
  - signing
  - authentication
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: ${K8SVersion}
controlPlaneEndpoint: ${Domain}:6443
imageRepository: ${ImageRepository}
networking:
  podSubnet: ${PodSubnet}
  serviceSubnet: ${ServiceSubnet}
etcd:
  local:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
apiServer:
  certSANs:
  - localhost
  - 127.0.0.1
  - ${Domain}
  - ${VIP}
  extraArgs:
    service-node-port-range: 30000-60000
  extraVolumes:
  - name: host-time
    hostPath: /etc/localtime
    mountPath: /etc/localtime
    readOnly: true
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
  extraVolumes:
  - name: host-time
    hostPath: /etc/localtime
    mountPath: /etc/localtime
    readOnly: true
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
  extraVolumes:
  - name: host-time
    hostPath: /etc/localtime
    mountPath: /etc/localtime
    readOnly: true
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
kubeReserved:
  cpu: 200m
  memory: 250Mi
systemReserved:
  cpu: 200m
  memory: 250Mi
evictionHard:
  memory.available: 5%
evictionSoft:
  memory.available: 10%
evictionSoftGracePeriod:
  memory.available: 2m
EOF
    # GenCertSANS
    sshpass -p ${Password} ssh -T root@${Masters[0]%%=*} "mkdir -p /root/kubernetes/CNI"
    sshpass -p ${Password} scp /tmp/kubeadm-config.yaml root@${Masters[0]%%=*}:/root/kubernetes/kubeadm-config.yaml
}

echo -e "\033[32m ====> 分发 kubeadm-config.yaml 文件 \033[0m"
SendKubeadmconfig