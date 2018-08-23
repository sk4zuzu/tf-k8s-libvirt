#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

mkdir -p /etc/etcd/pki/ && cp -f /terraform/etcd-pki/{key,crt}/etcd* /etc/etcd/pki/

SHORT_HOSTNAME=$(hostname -s)
LOCAL_IPV4=$(hostname -i)

INITIAL_CLUSTER=`
for (( k = 1; k <= ${_COUNT}; k++ )); do
    IPV4="$(getent ahostsv4 ${_PREFIX}$k | head -n1 | cut -d' ' -f1)"
    echo ${_PREFIX}$k=https://$IPV4:2380
done | paste -sd,
`

cat >/etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name=$SHORT_HOSTNAME \\
  --cert-file=/etc/etcd/pki/etcd.crt \\
  --key-file=/etc/etcd/pki/etcd.key \\
  --peer-cert-file=/etc/etcd/pki/etcd-peer.crt \\
  --peer-key-file=/etc/etcd/pki/etcd-peer.key \\
  --trusted-ca-file=/etc/etcd/pki/etcd-ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/pki/etcd-ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls=https://$LOCAL_IPV4:2380 \\
  --listen-peer-urls=https://$LOCAL_IPV4:2380 \\
  --listen-client-urls=https://$LOCAL_IPV4:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls=https://$LOCAL_IPV4:2379 \\
  --initial-cluster-token=k8s \\
  --initial-cluster=$INITIAL_CLUSTER \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl start etcd

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
