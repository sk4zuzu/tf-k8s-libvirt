
resource "null_resource" "k8s-node" {
    depends_on = [ "libvirt_domain.k8s-node" ]

    count = "${var._enable_provisioning ? var._count : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-node.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "remote-exec" {
        inline = [
            "echo ${join("", var._depends_on)}",  # don't remove this
        ]
    }

    provisioner "local-exec" {
        command = <<-EOF
        $SCRIPT $MASTER $REMOTE
        EOF
        environment {
            SCRIPT = "${path.root}/k8s-node/local-exec/02-token-hash-sync.sh"
            MASTER = "ubuntu@${format("%s%d", var._master_prefix, 1)}"
            REMOTE = "ubuntu@${element(libvirt_domain.k8s-node.*.network_interface.0.addresses[count.index], 0)}"
        }
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/01-haproxy.sh",
            "sudo -iu root /terraform/remote-exec/02-node.sh",
        ]
    }
}

# vim:ts=4:sw=4:et:
