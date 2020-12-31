#!/bin/bash
set -ue
set -o pipefail
#
sed -i 's/\(KEEPALIVED_OPTIONS=\)"-D"/\1"-D -d -S 0"/' /etc/sysconfig/keepalived
cat > /etc/rsyslog.d/keepalived-log.conf << EOF
local0.*        /var/log/keepalived/keepalived.log
& stop
EOF

cat > /etc/logrotate.d/keepalived << \EOF
/var/log/keepalived/keepalived.log {
    daily
    copytruncate
    rotate 10
    missingok
    dateext
    notifempty
    compress
    sharedscripts
    postrotate
        /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
        /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
EOF