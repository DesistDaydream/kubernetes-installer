# 使用前需修改 defaults 目录下的变量值
1. `MasterVIP` 用于 keeaplived.conf、kubeadm-config.yaml 文件。若值空，则kubeadm-config.yaml文件内controlPlaneEndpoint的值为当前host的ip；如果不为空则使用MASTER_VIP的值作为controlPlaneEndpoint的值。
1. **keepalived.conf** 文件变量
   1. `InterfaceName` 指定要使用的网络设备的名称。比如 eth0
   1. `VirtualRouterID` 指定 virtual_router_id，id 一般为 VIP 的最后几个数字，比如 10.0.1.100，那么 id 为 100。
1. **kubernetes** 相关变量，主要作用与 kubeamd-config.yaml 文件。
   1. `KubernetesVersion` 指定要部署的 k8s 版本。比如 1.18.3
   1. `PodSubNet` 指定 k8s 为 pod 分配的 CIDR。注意需要与 CNI 的 CIDR 保持一致。
   1. `Proxy.Mode` 指定 k8s 的 kube-proxy 的运行模式
1. `Internet` 变量用于指定当前环境是在线还是离线。yes 为可以连接互联网。no 为不能连接互联网。
1. `templates/hosts.j2` 文件的最后一行用来解析镜像仓库，将ip和想要解析的域名换成本环境下的。

Note: 
1. 主机名命名规范：
   1. master的主机名一定要带有master，如果是高可用集群，则主机名需要带-，即master-，比如master-1。Node节点不能带master字符串。
