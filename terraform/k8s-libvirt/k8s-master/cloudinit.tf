
resource "libvirt_cloudinit" "k8s-master" {
    count = "${var._count}"
    name  = "${var._prefix}${count.index + 1}.iso"

    local_hostname     = "${var._prefix}${count.index + 1}"
    ssh_authorized_key = "${lookup(var.ssh_keys[0], "key_data")}"

    user_data = <<-EOF
    #cloud-config
    ssh_pwauth: false
    EOF
}

# vim:ts=4:sw=4:et:
