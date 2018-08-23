#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

MASTER=$1
REMOTE=$2

[ -n "$SSH_AGENT_PID" ]
[ -n "$SSH_AUTH_SOCK" ]

COMMON_OPTIONS="-o ForwardAgent=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

ssh $COMMON_OPTIONS $MASTER /bin/bash -s <<EOF
cd /etc/kubernetes/ && sudo -E rsync \
    -zvaR \
    --rsync-path="sudo rsync" \
    --rsh="ssh $COMMON_OPTIONS" \
    pki/ca.{key,crt} \
    pki/sa.{key,pub} \
    pki/front-proxy-ca.{key,crt} \
    admin.conf \
    {TOKEN,HASH} \
    $REMOTE:/etc/kubernetes/
EOF

# vim:ts=4:sw=4:et:syn=sh:
