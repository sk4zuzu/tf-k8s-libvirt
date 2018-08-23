#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

[ -f "$0.done" ] && exit 0

API_SERVER_CERT_SANS=`
echo "- local-lb"
for (( k = 1; k <= ${_COUNT}; k++ )); do
    IPV4="$(getent ahostsv4 ${_PREFIX}$k | head -n1 | cut -d' ' -f1)"
    echo "- $IPV4"
done
`

LOCAL_IPV4=$(hostname -i)

ENDPOINTS=`
for (( k = 1; k <= ${_COUNT}; k++ )); do
    IPV4="$(getent ahostsv4 ${_PREFIX}$k | head -n1 | cut -d' ' -f1)"
    echo "    - https://$IPV4:2379"
done
`

cat >/terraform/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.2
apiServerCertSANs:
$API_SERVER_CERT_SANS
api:
  controlPlaneEndpoint: local-lb:7878
  advertiseAddress: $LOCAL_IPV4
  bindPort: 6443
etcd:
  external:
    endpoints:
$ENDPOINTS
    caFile: /etc/etcd/pki/etcd-ca.crt
    certFile: /etc/etcd/pki/etcd.crt
    keyFile: /etc/etcd/pki/etcd.key
networking:
  podSubnet: 10.244.0.0/16
certificatesDir: /etc/kubernetes/pki/
EOF

touch "$0.done"

# vim:ts=4:sw=4:et:syn=sh:
