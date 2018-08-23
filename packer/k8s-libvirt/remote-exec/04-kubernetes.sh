#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://apt.kubernetes.io/ \
   kubernetes-$(lsb_release -cs) \
   main"

apt-get -q update -y

KUBERNETES_VERSION="1.11.2"
KUBERNETES_VERSION_APT="${KUBERNETES_VERSION}-00"
KUBERNETES_CNI_VERSION_APT="0.6.0-00"

apt-get -q install -y \
    kube{let,adm,ctl}=${KUBERNETES_VERSION_APT} \
    kubernetes-cni=${KUBERNETES_CNI_VERSION_APT}
apt-get -q clean

kubeadm reset --force

kubeadm config images pull --kubernetes-version="v${KUBERNETES_VERSION}"

HELM_VERSION="2.10.0"

curl -fsSL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    | tar -xz -f- -C /usr/local/bin/ --strip-components=1 linux-amd64/helm

sync

# vim:ts=4:sw=4:et:syn=sh:
