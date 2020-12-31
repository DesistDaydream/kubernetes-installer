# 部署前准备
务必仔细阅读该说明，确认好可以改动的地方，改动时，请仔细认真核对。

部署前，请参考 variables 章节规划集群配置文件。

**注意：如果想要正常部署，-p 选项必须作为第一个参数，使用 -p 指定所有服务器的密码。**

## variables 文件说明
[variables.sh](./variables/variables.sh) 文件中为可变的配置，通过修改该文件中变量值来自定义 dr 的部署行为。

**下面列出的参数是必须要根据当前环境修改的，其余没有列出的，不推荐修改。**

### 规划主机(必须修改项)
DR=(
'172.19.42.250=dr-1.tj-test'
'172.19.42.249=dr-2.tj-test'
)
VIP='172.19.42.248' # dr 的 VIP。

### 通用参数
online='no' # 当前脚本是在线环境还是离线安装使用。

### keepalived 参数
InterfaceName=ens192    # keepalived 所用网络设备，用于生成 VIP
ens192 可以理解为网卡名，效果如下
```
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

当配置完成后，执行 `bash main.sh -p Oc.com123 --install` 来部署 k8s 环境