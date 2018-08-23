#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

which terraform

ARGS=("$@")

CURRENT_WORKSPACE=`terraform workspace show`

[ -f "environment/${CURRENT_WORKSPACE}.tfvars" ]

[ -n "$SSH_AGENT_PID" ]
[ -n "$SSH_AUTH_SOCK" ]

exec terraform ${ARGS[@]} --var-file="environment/${CURRENT_WORKSPACE}.tfvars"

# vim:ts=4:sw=4:et:syn=sh:
