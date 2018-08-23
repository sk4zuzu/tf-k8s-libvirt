#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get -q update -y

DOCKER_CE_VERSION_APT="18.03.1~ce-0~ubuntu"

apt-get -q install -y \
    docker-ce=${DOCKER_CE_VERSION_APT}

apt-get -q clean

sync

# vim:ts=4:sw=4:et:syn=sh:
