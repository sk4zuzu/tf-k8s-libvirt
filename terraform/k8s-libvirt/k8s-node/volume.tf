
resource "libvirt_volume" "k8s-node-qcow2" {
    name   = "k8s-node-qcow2"
    pool   = "default"
    format = "qcow2"
    source = "${var._volume}"
}

resource "libvirt_volume" "k8s-node" {
    count          = "${var._count}"
    name           = "${var._prefix}${count.index + 1}"
    base_volume_id = "${libvirt_volume.k8s-node-qcow2.id}"
}

# vim:ts=4:sw=4:et:
