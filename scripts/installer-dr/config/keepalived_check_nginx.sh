#!/bin/bash
set -ue
set -o pipefail
#
cat > /etc/keepalived/check_nginx.sh << EOF
#!/bin/bash
pidof nginx
if [[ $? == 0 ]];then
  /sbin/iptables -S | grep vrrp
  if [[ $? == 0 ]]; then
    /sbin/iptables -D OUTPUT -p vrrp -j DROP
  fi
  exit 0
else
  /sbin/iptables -S | grep vrrp
  if [[ $? != 0 ]]; then
    /sbin/iptables -A OUTPUT -p vrrp -j DROP
  fi
  exit 1
fi
EOF

chmod 755 /etc/keepalived/check_nginx.sh