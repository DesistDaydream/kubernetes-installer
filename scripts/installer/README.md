# 部署前准备
务必仔细阅读该说明，确认好可以改动的地方，改动时，请仔细认真核对。

部署前，请参考 variables 章节规划集群配置文件。

**注意：如果想要正常部署，-p 选项必须作为第一个参数，使用 -p 指定所有服务器的密码。**

更多部署文档，详见[语雀文档](https://www.yuque.com/books/share/881ad728-b28a-49ba-94df-67b639c1c7ca/qzanwh)

## variables 文件说明
[variables.sh](./variables/variables.sh) 文件中为可变的配置，通过修改该文件中变量值来自定义 k8s 的部署行为。

**下面列出的参数是必须要根据当前环境修改的，其余没有列出的，不推荐修改。**

### 规划主机(必须修改项)
**主机名必须是 `master-X.XXXX` 这种形式，如果 master 节点仅需一个，则主机名必须是 `master.XXX` 这种形式**
```shell
Masters=(
'172.38.40.212=master-1.tj-test'
'172.38.40.213=master-2.tj-test'
'172.38.40.214=master-3.tj-test'
)
Nodes=(
'172.38.40.216=node-1.tj-test'
'172.38.40.217=node-2.tj-test'
)
Domain='k8s-api.tj-test.ehualu.local' # VIP 的域名，只将 tj-test 修改为 `地点-作用` 这种格式即可。
VIP='172.38.40.215' # master 集群的 VIP。若是单 master 节点，则 VIP 需要改为 master 的 IP，二者要保持一致。
```
>Domain 和 VIP 也是 K8S 集群的入口，各种客户端与 API Service 通信的地址

### 通用参数
```shell
online='no' # 当前脚本是在线环境还是离线安装使用。
```

### docker 参数
```shell
InsecureRegistries='"registry.tj-test.ehualu.com","172.38.50.130"' # docker 连接不安全的私有镜像仓库的地址，！！！注意格式不要变。
DefaultAddressPools='10.38.0.0/16' # docker 桥的 IP
```

### VIP 参数
```shell
InterfaceName=ens192 # 用于生成 VIP 的网络设备名称
# ens192 可以理解为网卡名，效果如下
```
```shell
[root@master-1 pods]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:64:50:5a brd ff:ff:ff:ff:ff:ff
    inet 172.38.40.212/24 brd 172.38.40.255 scope global noprefixroute ens192
       valid_lft forever preferred_lft forever
```

### 镜像仓库参数，用于配置 hosts 解析
若使用不安全的镜像仓库，则为 hosts 文件添加如下解析，与 docker 参数中 InsecureRegistries 保持一致
```shell
RegistryIP='172.38.50.130'
RegistryHost='registry.tj-test.ehualu.com'
```

### kubernetes 参数
略

配置完成后，执行 `bash main.sh -p 你的密码 --install` 命令部署 k8s 环境

# 要求和建议
* 最低资源要求
  * 2 个 vCPU
  * 4 GB 内存
  * 20 GB 存储空间

> /var/lib/docker 主要用于存放容器数据，在使用和运行过程中会逐渐变大。如果是生产环境，建议 /var/lib/docker 单独挂载一个驱动。

* 操作系统要求：
  * `SSH` 可以访问所有节点。
  * 所有节点的时间同步。
  * `sudo`/`curl`/`openssl` 应该在所有节点中使用。
  * `docker` 可以自己安装，也可以通过 KubeKey 安装。
  * `Red Hat` 在它的 `Linux release` 中包含了 `SELinux`。建议关闭SELinux或【切换SELinux模式】(./docs/turn-off-SELinux.md)为`Permissive`
> * 建议您的操作系统是干净的（没有安装任何其他软件），否则可能会发生冲突。  
> * 如果在dockerhub.io 下载镜像有问题，建议准备一个容器镜像（加速器）。[为 Docker 守护进程配置注册表镜像](https://docs.docker.com/registry/recipes/mirror/#configure-the-docker-daemon)。
> * 如果在复制时遇到`Permission denied`，建议先勾选【SELinux 并关闭】(./docs/turn-off-SELinux.md) 

* 依赖要求：

下面的依赖，使用包管理工具即可安装
| | |
| ----------- | ------------------------- |
| `socat` | 必填 |
| `conntrack` | 必填 |
| `ebtables` | 可选但推荐 |
| `ipset` | 可选但推荐 |

* 网络和 DNS 要求：
  * 确保`/etc/resolv.conf` 中的DNS 地址可用。否则，可能会导致集群中的 DNS 出现一些问题。
  * 如果您的网络配置使用防火墙或安全组，您必须确保基础设施组件可以通过特定端口相互通信。建议您关闭防火墙或按照链接配置：[NetworkAccess](docs/network-access.md)。

# 部署完成后操作
为指定节点添加标签以运行 nginx-ingress-controller
```bash
kubectl label nodes node-1.bj-test node-role.kubernetes.io/proxy=ingress-controller
```