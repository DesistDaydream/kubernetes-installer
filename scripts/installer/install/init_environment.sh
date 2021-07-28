#!/bin/bash
set -ue
set -o pipefail
#
# EnviromentInit 初始化系统环境
function EnviromentInit(){
    if [[ `systemctl status firewalld.service &> /dev/null` == "0" ]]; then
        systemctl stop firewalld.service; systemctl disable firewalld.service
    fi
    if [[ -e /etc/selinux/config ]];then sed -i 's@^\(SELINUX=\).*@\1disabled@' /etc/selinux/config; fi
    if setenforce 0 &> /dev/null; then echo "关闭 selinux"; fi
    swapoff -a
    sed -i 's@^[^#]\(.*swap.*\)@#\1@g' /etc/fstab

    cat > /etc/security/limits.d/max-openfile.conf  << EOF
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

    cat > /etc/modules-load.d/ip_vs.conf << EOF
ip_vs
ip_vs_lblc
ip_vs_lblcr
ip_vs_lc
ip_vs_nq
ip_vs_pe_sip
ip_vs_rr
ip_vs_sed
ip_vs_sh
ip_vs_wlc
ip_vs_wrr
EOF
    for i in `cat /etc/modules-load.d/ip_vs.conf`; do modprobe ${i}; done
}

EnviromentInit