
resource "libvirt_domain" "k8s-node" {
    depends_on = [ "libvirt_cloudinit.k8s-node" ]

    count = "${var._count}"
    name  = "${var._prefix}${count.index + 1}"

    vcpu   = "${var.vcpu}"
    memory = "${var.memory}"

    cloudinit = "${element(libvirt_cloudinit.k8s-node.*.id, count.index)}"

    network_interface {
        network_id     = "${var.network_id[0]}"
        wait_for_lease = true
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }

    disk {
        volume_id = "${element(libvirt_volume.k8s-node.*.id, count.index)}"
	}
}

# vim:ts=4:sw=4:et:
