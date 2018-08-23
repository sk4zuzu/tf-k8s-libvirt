#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
set -x

which docker packer /bin/rm

VERSION="16.04"
IMAGE="ubuntu-${VERSION}-server-cloudimg-amd64-disk1.img"
SHA256=b9fabb10582ac3ba343db3edbd77499b7be1c113a62f2ca8f58dd0679ae85a20

DISK_SIZE="$((16*1024))"

CLOUD_CONFIG="
#cloud-config
password: ubuntu
ssh_pwauth: true
chpasswd:
  expire: false
"

function cleanup {
    if [ -f $IMAGE.iso ]; then
        /bin/rm -f $IMAGE.iso
    fi
}

trap cleanup EXIT

echo ">>> prepare temporary docker image <<<"

docker build -t $IMAGE remote-exec/ -f- <<EOF
FROM ubuntu:$VERSION

RUN apt-get -q update -y \
 && apt-get -q install -y --no-install-recommends cloud-utils

CMD /bin/bash
EOF

echo ">>> generate cloud-init iso image with config <<<"

docker run --rm -i $IMAGE /bin/bash -s >$IMAGE.iso <<EOF
cloud-localds /dev/stdout <(echo "$CLOUD_CONFIG")
EOF

echo ">>> modify source disk image <<<"

packer build -force - <<EOF
{
  "builders": [
    {
      "type": "qemu",
      "headless": "true",
      "accelerator": "kvm",

      "disk_image": "true",
      "iso_url": "https://cloud-images.ubuntu.com/releases/${VERSION}/release/${IMAGE}",
      "iso_checksum": "$SHA256",
      "iso_checksum_type": "sha256",

      "disk_size": "$DISK_SIZE",

      "qemuargs": [
        ["-fda", "$IMAGE.iso"]
      ],

      "ssh_username": "ubuntu",
      "ssh_password": "ubuntu",

      "output_directory": "$IMAGE",
      "vm_name": "qcow2"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "script": "remote-exec/01-basics.sh",
      "execute_command": "sudo -iu root '{{ .Path }}'"
    },
    {
      "type": "shell",
      "script": "remote-exec/02-docker.sh",
      "execute_command": "sudo -iu root '{{ .Path }}'"
    },
    {
      "type": "shell",
      "script": "remote-exec/03-etcd.sh",
      "execute_command": "sudo -iu root '{{ .Path }}'"
    },
    {
      "type": "shell",
      "script": "remote-exec/04-kubernetes.sh",
      "execute_command": "sudo -iu root '{{ .Path }}'"
    },
    {
      "type": "shell",
      "script": "remote-exec/05-haproxy.sh",
      "execute_command": "sudo -iu root '{{ .Path }}'"
    }
  ]
}
EOF

echo ">>> done <<<"

# vim:ts=4:sw=4:et:syn=sh:
