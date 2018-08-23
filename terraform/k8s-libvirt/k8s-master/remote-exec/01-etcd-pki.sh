#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

mkdir -p /terraform/etcd-pki/{crt,key,csr}/ && cd /terraform/etcd-pki/

ALT_NAMES_ETCD=`
for (( k = 1; k <= ${_COUNT}; k++ )); do
    IPV4="$(getent ahostsv4 ${_PREFIX}$k | head -n1 | cut -d' ' -f1)"
    echo DNS.$k = ${_PREFIX}$k
    echo IP.$k  = $IPV4
done
`

cat >openssl.cnf <<EOF
[ req ]
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign
[ v3_req_etcd ]
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names_etcd
[ alt_names_etcd ]
$ALT_NAMES_ETCD
EOF

openssl genrsa \
    -out key/etcd-ca.key \
    4096

openssl req -x509 -new \
    -sha256 \
    -nodes \
    -key key/etcd-ca.key \
    -days 3650 \
    -out crt/etcd-ca.crt \
    -subj "/CN=etcd-ca" \
    -extensions v3_ca \
    -config openssl.cnf

openssl genrsa \
    -out key/etcd.key \
    4096

openssl req -new \
    -sha256 \
    -key key/etcd.key \
    -subj "/CN=etcd" \
    -out csr/etcd.csr

openssl x509 -req \
    -in csr/etcd.csr \
    -sha256 \
    -CA crt/etcd-ca.crt \
    -CAkey key/etcd-ca.key \
    -CAcreateserial \
    -out crt/etcd.crt \
    -days 365 \
    -extensions v3_req_etcd \
    -extfile openssl.cnf

openssl genrsa \
    -out key/etcd-peer.key \
    4096

openssl req -new \
    -sha256 \
    -key key/etcd-peer.key \
    -subj "/CN=etcd-peer" \
    -out csr/etcd-peer.csr

openssl x509 -req \
    -in csr/etcd-peer.csr \
    -sha256 \
    -CA crt/etcd-ca.crt \
    -CAkey key/etcd-ca.key \
    -CAcreateserial \
    -out crt/etcd-peer.crt \
    -days 365 \
    -extensions v3_req_etcd \
    -extfile openssl.cnf

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
