
resource "null_resource" "k8s-master-etcd-pki" {
    depends_on = [ "libvirt_domain.k8s-master" ]

    count = "${var._enable_provisioning ? (var._count > 0 ? 1 : 0) : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/01-etcd-pki.sh",
        ]
    }
}

resource "null_resource" "k8s-master-etcd-pki-sync" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
    ]

    count = "${var._enable_provisioning ? (var._count > 1 ? var._count - 1 : 0) : 0}"  # skipping master1

    provisioner "local-exec" {
        command = <<-EOF
        $SCRIPT $MASTER $REMOTE
        EOF
        environment {
            SCRIPT = "${path.root}/k8s-master/local-exec/02-etcd-pki-sync.sh"
            MASTER = "ubuntu@${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[0], 0)}"
            REMOTE = "ubuntu@${format("%s%d", var._prefix, count.index + 2)}"  # skipping master1
        }
    }
}

resource "null_resource" "k8s-master-etcd-init" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
        "null_resource.k8s-master-etcd-pki-sync",
    ]

    count = "${var._enable_provisioning ? var._count : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/02-etcd-init.sh",
        ]
    }
}

resource "null_resource" "k8s-master-haproxy" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
        "null_resource.k8s-master-etcd-pki-sync",
        "null_resource.k8s-master-etcd-init",
    ]

    count = "${var._enable_provisioning ? var._count : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/03-haproxy.sh",
        ]
    }
}

resource "null_resource" "k8s-master-preload" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
        "null_resource.k8s-master-etcd-pki-sync",
        "null_resource.k8s-master-etcd-init",
        "null_resource.k8s-master-haproxy",
    ]

    count = "${var._enable_provisioning ? var._count : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/04-master-preload.sh",
        ]
    }
}

resource "null_resource" "k8s-master-init" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
        "null_resource.k8s-master-etcd-pki-sync",
        "null_resource.k8s-master-etcd-init",
        "null_resource.k8s-master-haproxy",
        "null_resource.k8s-master-preload",
    ]

    count = "${var._enable_provisioning ? (var._count > 0 ? 1 : 0) : 0}"

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index], 0)}"
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/05-master-init.sh",
            "sudo -iu root /terraform/remote-exec/06-helm.sh",
        ]
    }

    provisioner "local-exec" {
        command = <<-EOF
        $SCRIPT $MASTER
        EOF
        environment {
            SCRIPT = "${path.root}/k8s-master/local-exec/07-kubeconfig-sync.sh"
            MASTER = "ubuntu@${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[0], 0)}"
        }
    }
}

resource "null_resource" "k8s-master-replicate" {
    depends_on = [
        "null_resource.k8s-master-etcd-pki",
        "null_resource.k8s-master-etcd-pki-sync",
        "null_resource.k8s-master-etcd-init",
        "null_resource.k8s-master-haproxy",
        "null_resource.k8s-master-preload",
        "null_resource.k8s-master-init",
    ]

    count = "${var._enable_provisioning ? (var._count > 1 ? var._count - 1 : 0) : 0}"  # skipping master1

    provisioner "local-exec" {
        command = <<-EOF
        $SCRIPT $MASTER $REMOTE
        EOF
        environment {
            SCRIPT = "${path.root}/k8s-master/local-exec/05-master-pki-sync.sh"
            MASTER = "ubuntu@${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[0], 0)}"
            REMOTE = "ubuntu@${format("%s%d", var._prefix, count.index + 2)}"  # skipping master1
        }
    }

    connection = {
        type  = "ssh"
        user  = "ubuntu"
        host  = "${element(libvirt_domain.k8s-master.*.network_interface.0.addresses[count.index + 1], 0)}"  # skipping master1
        agent = true
    }

    provisioner "file" {
        source      = "${template_dir.remote-exec.destination_dir}"
        destination = "/terraform/remote-exec"
    }

    provisioner "remote-exec" {
        inline = [
            "set -o errexit",
            "find /terraform/remote-exec -type f -name '*.sh' | xargs chmod +x",
            "sudo -iu root /terraform/remote-exec/05-master-replicate.sh",
        ]
    }
}

# vim:ts=4:sw=4:et:
