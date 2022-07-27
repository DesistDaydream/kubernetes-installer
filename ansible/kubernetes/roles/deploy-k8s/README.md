# 使用前需修改 defaults 目录下的变量值

1. `master_vip` 用于 keeaplived.conf、kubeadm-config.yaml 文件。若值空，则 kubeadm-config.yaml 文件内 controlPlaneEndpoint 的值为当前 host 的 ip；如果不为空则使用 MASTER_VIP 的值作为 controlPlaneEndpoint 的值。
1. `master_vip_interface` 指定要使用的网络设备的名称。比如 eth0
1. **kubernetes** 相关变量，主要作用与 kubeamd-config.yaml 文件。
   1. `kubernetes_version` 指定要部署的 k8s 版本。比如 1.18.3
   1. `pod_subnet` 指定 k8s 为 pod 分配的 CIDR。注意需要与 CNI 的 CIDR 保持一致。
   1. `proxy.mode` 指定 k8s 的 kube-proxy 的运行模式
1. `install_method` 变量用于指定当前环境是在线还是离线。yes 为可以连接互联网。no 为不能连接互联网。
1. `templates/hosts.j2` 文件的最后一行用来解析镜像仓库，将 ip 和想要解析的域名换成本环境下的。

Note:

1. 主机名命名规范：
   1. master 的主机名一定要带有 master，如果是高可用集群，则主机名需要带-，即 master-，比如 master-1。Node 节点不能带 master 字符串。
