# 部署前准备
务必仔细阅读该说明，确认好可以改动的地方，改动时，请仔细认真核对。

部署前，请参考 variables 章节规划集群配置文件。

**注意：如果想要正常部署，-p 选项必须作为第一个参数，使用 -p 指定所有服务器的密码。**

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

### keepalived 参数
```shell
InterfaceName=ens192 # keepalived 所用网络设备，用于生成 VIP
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