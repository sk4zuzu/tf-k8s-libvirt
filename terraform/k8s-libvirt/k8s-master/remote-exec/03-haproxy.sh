#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

BACKEND_SERVERS=`
for (( k = 1; k <= ${_COUNT}; k++ )); do
    IPV4="$(getent ahostsv4 ${_PREFIX}$k | head -n1 | cut -d' ' -f1)"
    echo "    server ${_PREFIX}$k $IPV4:6443 check port 6443"
done
`

mkdir -p /etc/haproxy/ && cat >/etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
defaults
    log global
    retries 3
    maxconn 2000
    timeout connect 5s
    timeout client 50s
    timeout server 50s
frontend k8s
    mode tcp
    bind 0.0.0.0:7878
    default_backend k8s
backend k8s
    mode tcp
    balance roundrobin
    option tcp-check
$BACKEND_SERVERS
EOF

systemctl daemon-reload && systemctl start haproxy

if ! grep local-lb /etc/hosts; then
    echo "$(hostname -i) local-lb" >>/etc/hosts
fi

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
