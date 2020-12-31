#!/bin/bash
set -ue
set -o pipefail
#
cat > /etc/keepalived/check_apiserver.sh << EOF
#!/bin/sh
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}
curl --silent --max-time 2 --insecure https://localhost:6443/healthz -o /dev/null || errorExit "Error GET https://localhost:6443/healthz"
if ip addr | grep -q ${VIP}; then
    curl --silent --max-time 2 --insecure https://${VIP}:6443/healthz -o /dev/null || errorExit "Error GET https://${VIP}:6443/healthz"
fi
EOF
chmod 755 /etc/keepalived/check_apiserver.sh