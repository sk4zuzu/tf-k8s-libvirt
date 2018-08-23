
resource "libvirt_volume" "k8s-master-qcow2" {
    name   = "k8s-master-qcow2"
    pool   = "default"
    format = "qcow2"
    source = "${var._volume}"
}

resource "libvirt_volume" "k8s-master" {
    count          = "${var._count}"
    name           = "${var._prefix}${count.index + 1}"
    base_volume_id = "${libvirt_volume.k8s-master-qcow2.id}"
}

# vim:ts=4:sw=4:et:
