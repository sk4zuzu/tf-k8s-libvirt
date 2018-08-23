#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

HAPROXY_VERSION="1.8.12"

curl -fsSL http://www.haproxy.org/download/`cut -d. -f1-2 <<< ${HAPROXY_VERSION}`/src/haproxy-${HAPROXY_VERSION}.tar.gz \
    | tar -xz -f- -C /terraform

cd /terraform/haproxy-${HAPROXY_VERSION}/

BUILD_DEPS="make gcc libpcre3-dev zlib1g-dev libsystemd-dev"

apt-get -q install -y ${BUILD_DEPS}

make TARGET=linux2628 USE_SYSTEMD=1 && /bin/cp haproxy /usr/local/bin

apt-get -q remove -y ${BUILD_DEPS} && apt-get -q autoremove -y

cat >/etc/systemd/system/haproxy.service <<EOF
[Unit]
Description=HAProxy Load Balancer
After=network.target

[Service]
ExecStartPre=/usr/local/bin/haproxy -f /etc/haproxy/haproxy.cfg -c -q
ExecStart=/usr/local/bin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
ExecReload=/usr/local/bin/haproxy -f /etc/haproxy/haproxy.cfg -c -q
ExecReload=/bin/kill -USR2 \$MAINPID
KillMode=mixed
Restart=always
SuccessExitStatus=143
Type=notify

[Install]
WantedBy=multi-user.target
EOF

sync

# vim:ts=4:sw=4:et:syn=sh:
