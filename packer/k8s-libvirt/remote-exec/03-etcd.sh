#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

ETCD_VERSION="3.3.8"

curl -fsSL https://storage.googleapis.com/etcd/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
    | tar -xz -f- -C /usr/local/bin/ --strip-components=1 etcd-v${ETCD_VERSION}-linux-amd64/etcd{,ctl}

mkdir -p /etc/etcd/pki/

sync

# vim:ts=4:sw=4:et:syn=sh:
