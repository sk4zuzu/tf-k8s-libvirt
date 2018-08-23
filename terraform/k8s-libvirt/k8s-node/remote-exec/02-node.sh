#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

TOKEN=$(head -n1 /etc/kubernetes/TOKEN)
HASH=$(head -n1 /etc/kubernetes/HASH)

[ -n "$TOKEN" ]
[ -n "$HASH" ]

kubeadm join \
    --token="$TOKEN" \
    --discovery-token-ca-cert-hash="sha256:$HASH" \
    local-lb:7878

cat >/etc/profile.d/kubeconfig.sh <<EOF
export KUBECONFIG=/etc/kubernetes/kubelet.conf
EOF

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
