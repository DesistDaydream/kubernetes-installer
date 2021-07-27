#!/bin/bash
set -ue
set -o pipefail
#
source /root/downloads/variables.sh
if [[ ${#Nodes[@]} -gt "0" ]]; then
    AllNodes=("${Masters[@]}" "${Nodes[@]}")
else
    AllNodes=("${Masters[@]}")
fi

# GenHosts 生成 hosts 文件，在目标节点执行命令
function GenHosts(){
    sed -i ':a;$!{N;ba};s@# hosts BEGIN.*# hosts END@@' /etc/hosts
    sed -i '/^$/N;/\n$/N;//D' /etc/hosts
    cat >> /etc/hosts << EOF
# hosts BEGIN
# hosts END
EOF
    for i in ${!AllNodes[@]}; do
        sed -i "/hosts END/i${AllNodes[${i}]%%=*} ${AllNodes[${i}]##*=}" /etc/hosts
    done

    # 根据 master 数量，生成与 api 交互的域名解析
    if [[ "${#Masters[@]}" -gt "1" ]]; then APIIP=${VIP}; else APIIP=${Masters[0]%%=*}; fi
    sed -i "/hosts END/i${APIIP} ${Domain}" /etc/hosts

    sed -i "/hosts END/i${RegistryIP} ${RegistryHost}" /etc/hosts
}

GenHosts
