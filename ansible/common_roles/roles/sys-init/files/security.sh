#!/bin/bash
#
function main(){
    mkdir -p /root/backup
    if [ -e /usr/lib/systemd/system/ctrl-alt-del.target ]; then
        mv /usr/lib/systemd/system/ctrl-alt-del.target /root/backup/
    fi

    # 登录失败锁定账户、检查密码强度
    sudo tee /etc/pam.d/password-auth-local > /dev/null <<EOF
auth        required       pam_faillock.so preauth  audit deny=3 even_deny_root unlock_time=60 root_unlock_time=30
auth        include        password-auth-ac
auth        [default=die]  pam_faillock.so authfail audit deny=3 even_deny_root unlock_time=60 root_unlock_time=30

account     required       pam_faillock.so
account     include        password-auth-ac

password    include        password-auth-ac

session     include        password-auth-ac
EOF

    if [ ! -e /etc/pam.d/password-auth.src ]; then
        cp /etc/pam.d/password-auth{,.src}
    fi
    if [ ! -e /etc/pam.d/password-auth-ac ]; then
        cp /etc/pam.d/password-auth{,-ac}
    fi
    sed -i 's/\(^auth.*quiet_success\)/#\1/' /etc/pam.d/password-auth-ac
    ln -sf /etc/pam.d/password-auth-local /etc/pam.d/password-auth

    sudo tee /etc/pam.d/system-auth-local > /dev/null <<EOF
auth        required       pam_faillock.so preauth  audit deny=3 even_deny_root unlock_time=60 root_unlock_time=30
auth        include        system-auth-ac
auth        [default=die]  pam_faillock.so authfail audit deny=3 even_deny_root unlock_time=60 root_unlock_time=30

account     required       pam_faillock.so
account     include        system-auth-ac

# 验证密码强度，通过 /etc/security/pwquality.conf 配置文件配置强度要求
password    required       pam_pwquality.so retry=3
# 设置的新密码不能与历史上5次的密码相同
password    requisite      pam_pwhistory.so remember=5
password    include        system-auth-ac

session     include        system-auth-ac
EOF

    if [ ! -e /etc/pam.d/system-auth.src ]; then
        cp /etc/pam.d/system-auth{,.src}
    fi
    if [ ! -e /etc/pam.d/system-auth-ac ]; then
        cp /etc/pam.d/system-auth{,-ac}
    fi
    sed -i 's/\(^auth.*quiet_success\)/#\1/' /etc/pam.d/system-auth-ac
    ln -sf /etc/pam.d/system-auth-local /etc/pam.d/system-auth

    if [ ! -e /etc/pam.d/su.src ]; then
        cp /etc/pam.d/su{,.src}
    fi
    # sed -i 's/#\(auth\t\tsufficient\tpam_wheel.so trust use_uid\)/\1/' /etc/pam.d/su
    sed -i 's/#\(auth\t\trequired\tpam_wheel.so use_uid\)/\1/' /etc/pam.d/su

    if [ ! -e /etc/login.defs.src ]; then
        cp /etc/login.defs{,.src}
    fi
    sed -i 's/^\(PASS_MAX_DAYS\t\).*/\190/' /etc/login.defs
    sed -i 's/^\(PASS_MIN_LEN\t\).*/\18/' /etc/login.defs
    sed -i 's/^\(PASS_MIN_DAYS\t\).*/\16/' /etc/login.defs
    sed -i 's/^\(PASS_WARN_AGE\t\).*/\130/' /etc/login.defs

    echo "Login success. All activity will be monitored and reported " > /etc/motd

    cat > /etc/security/limits.d/custom_other.conf <<END
* hard core 0
* soft core 0
END

#     cat > /etc/profile.d/custom_other.sh <<EOF
# umask 077
# EOF
}

main