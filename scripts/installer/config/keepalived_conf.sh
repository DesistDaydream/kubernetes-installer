#!/bin/bash
set -ue
set -o pipefail
#
case $(hostname) in
"${Masters[0]##*=}")
    KeepalivedPriority=101
    KeepalivedState=MASTER
    ;;
"${Masters[1]##*=}")
    KeepalivedPriority=100
    KeepalivedState=BACKUP
    ;;
"${Masters[2]##*=}")
    KeepalivedPriority=99
    KeepalivedState=BACKUP
    ;;
*)
    echo "[ERROR] 各 master 节点主机名配置出现问题，请检查，也许是脚本中没有执行配置主机名的操作？"
    exit 1
esac

cat > /etc/keepalived/keepalived.conf << EOF
global_defs {
    router_id k8s-master-dr
    script_user root
    enable_script_security
}

vrrp_script check_apiserver {
    script "/bin/bash /etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_K8S {
    state ${KeepalivedState}
    interface ${InterfaceName}
    virtual_router_id ${VIP##*.}
    priority ${KeepalivedPriority}
    authentication {
        auth_type PASS
        auth_pass 4be37dc3b4c90194d1600c483e10ad1d
    }
    virtual_ipaddress {
        ${VIP}
    }
    track_script {
        check_apiserver
    }
}
EOF