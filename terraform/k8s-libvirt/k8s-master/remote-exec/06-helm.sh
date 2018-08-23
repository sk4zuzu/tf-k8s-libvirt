#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

source /etc/profile.d/kubeconfig.sh

kubectl create \
    serviceaccount \
    --namespace="kube-system" \
    tiller

kubectl create \
    clusterrolebinding \
    tiller-cluster-rule \
    --clusterrole="cluster-admin" \
    --serviceaccount="kube-system:tiller"

helm init \
    --service-account="tiller" \
    --upgrade

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
