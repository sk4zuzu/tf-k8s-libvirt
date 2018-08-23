#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

MASTER=$1

[ -n "$SSH_AGENT_PID" ]
[ -n "$SSH_AUTH_SOCK" ]

COMMON_OPTIONS="-o ForwardAgent=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

mkdir -p ~/.kube/ && rsync \
    -zva \
    --rsync-path="sudo rsync" \
    --rsh="ssh $COMMON_OPTIONS" \
    $MASTER:/etc/kubernetes/admin.conf \
    ~/.kube/config

sed -i "s|server: https://local-lb:7878|server: https://${MASTER#*@}:7878|" ~/.kube/config

# vim:ts=4:sw=4:et:syn=sh:
