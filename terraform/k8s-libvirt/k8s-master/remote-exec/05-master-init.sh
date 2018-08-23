#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

kubeadm init --config="/terraform/kubeadm-config.yaml"

cat >/etc/profile.d/kubeconfig.sh <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

source /etc/profile.d/kubeconfig.sh

kubectl create \
    --namespace="kube-system" \
    -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

TOKEN=$(kubeadm token create --ttl=0 --groups=system:bootstrappers:kubeadm:default-node-token)
[ -n "$TOKEN" ] && echo $TOKEN >/etc/kubernetes/TOKEN

HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der | openssl dgst -sha256 -hex | grep stdin | cut -d" " -f2)
[ -n "$HASH" ] && echo $HASH >/etc/kubernetes/HASH

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
