#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

apt-get -q update -y

apt-get -q install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

apt-get -q install -y --no-install-recommends \
    pv \
    vim mc htop \
    net-tools iproute2 netcat nmap \
    iftop nethogs \
    jq

apt-get -q clean

install -d -o root -g ubuntu -m ug=rwx,o= /terraform{,/remote-exec}

sync

# vim:ts=4:sw=4:et:syn=sh:
