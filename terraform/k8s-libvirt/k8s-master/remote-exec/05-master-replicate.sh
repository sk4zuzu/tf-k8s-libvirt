#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0


kubeadm alpha phase \
    certs all --config="/terraform/kubeadm-config.yaml"

kubeadm alpha phase \
    kubelet config write-to-disk --config="/terraform/kubeadm-config.yaml"

kubeadm alpha phase \
    kubelet write-env-file --config="/terraform/kubeadm-config.yaml"

kubeadm alpha phase \
    kubeconfig kubelet --config="/terraform/kubeadm-config.yaml"


systemctl start kubelet


kubeadm alpha phase \
    kubeconfig all --config="/terraform/kubeadm-config.yaml"

kubeadm alpha phase \
    controlplane all --config="/terraform/kubeadm-config.yaml"

kubeadm alpha phase \
    mark-master --config="/terraform/kubeadm-config.yaml"


cat >/etc/profile.d/kubeconfig.sh <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

source /etc/profile.d/kubeconfig.sh


touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
