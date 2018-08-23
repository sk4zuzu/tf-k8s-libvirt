
resource "libvirt_network" "k8s" {
    name      = "k8s"
    mode      = "nat"
    domain    = "k8s.local"
    addresses = [ "${lookup(var.network[0], "subnet")}" ]
}

# vim:ts=4:sw=4:et:
