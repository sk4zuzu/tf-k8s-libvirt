#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

MASTER=$1
REMOTE=$2

[ -n "$SSH_AGENT_PID" ]
[ -n "$SSH_AUTH_SOCK" ]

COMMON_OPTIONS="-o ForwardAgent=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

ssh $COMMON_OPTIONS $REMOTE /bin/bash -s <<EOF
mkdir -p /etc/kubernetes/ && sudo -E rsync \
    -zvaR \
    --rsync-path="sudo rsync" \
    --rsh="ssh $COMMON_OPTIONS" \
    $MASTER:/etc/kubernetes/{TOKEN,HASH} \
    /
EOF

# vim:ts=4:sw=4:et:syn=sh:
