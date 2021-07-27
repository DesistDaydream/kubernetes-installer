# 规划主机
Masters=(
'172.38.40.212=master-1.tj-test'
'172.38.40.213=master-2.tj-test'
'172.38.40.214=master-3.tj-test'
)
Nodes=(
'172.38.40.216=node-1.tj-test'
'172.38.40.217=node-2.tj-test'
'172.38.40.218=node-3.tj-test'
)
Domain='k8s-api.tj-test.ehualu.local'
VIP='172.38.40.215'

# 通用配置
online='no'

# docker 配置
DockerVersion='20.10.6'
InsecureRegistries='"registry.tj-test.ehualu.com","172.38.50.130"'
DefaultAddressPools='10.38.0.0/16'

# keepalived 配置
KeepalivedVersion='1.3.5'
InterfaceName='eth0'

# kubernetes 配置
K8SVersion='v1.19.2'
ImageRepository='registry.aliyuncs.com/k8sxio'
DnsDomain='cluster.local'
ServiceSubnet='10.96.0.0/12'
PodSubnet='10.244.0.0/16'

# CNI 配置
FlannelType='host-gw'

# 镜像仓库配置,用于配置 hosts 文件
RegistryIP='172.38.50.130'
RegistryHost='registry.tj-test.ehualu.com'

# 测试
# Masters=(
# '172.38.40.250=master'
# )
# Nodes=(
# '172.38.40.219=node-1'
# )
# Domain='k8s-api.tj-test.ehualu.local'
# VIP='172.38.40.250'
