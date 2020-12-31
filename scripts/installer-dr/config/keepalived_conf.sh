#!/bin/bash
set -ue
set -o pipefail
#
case $(hostname) in
"${DR[0]##*=}")
    KeepalivedPriority=101
    ;;
"${DR[1]##*=}")
    KeepalivedPriority=100
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
    script "/etc/keepalived/check_nginx.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_K8S {
    state BACKUP
    interface ${InterfaceName}
    virtual_router_id ${VIP##*.}
    priority ${KeepalivedPriority}
    nopreempt
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