#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

which ssh virsh awk

[ -n "$SSH_AGENT_PID" ]
[ -n "$SSH_AUTH_SOCK" ]

MASTER1_IPV4=`
virsh net-dhcp-leases k8s | awk '/master1/{ split($5,a,"/"); print a[1]; }'
`

[ -n "$MASTER1_IPV4" ]

COMMON_OPTIONS="-o ForwardAgent=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

exec ssh $COMMON_OPTIONS ubuntu@$MASTER1_IPV4 -t "$@"

# vim:ts=4:sw=4:et:syn=sh:
