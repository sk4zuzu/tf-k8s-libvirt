
module "k8s-master" {
    source = "./k8s-master"

    _enable_provisioning = "${var._enable_provisioning}"

    _depends_on = []

    _count  = "${var._k8s_master["_count"]}"
    _prefix = "${var._k8s_master["_prefix"]}"

    _volume = "${var._k8s_master["_volume"]}"

    vcpu   = "${var._k8s_master["vcpu"]}"
    memory = "${var._k8s_master["memory"]}"

    ssh_keys = "${var.ssh_keys}"

    network_id = [
        "${libvirt_network.k8s.id}",
    ]
}

module "k8s-node" {
    source = "./k8s-node"

    _enable_provisioning = "${var._enable_provisioning}"

    _depends_on = [
        "${module.k8s-master.done}",
    ]

    _count  = "${var._k8s_node["_count"]}"
    _prefix = "${var._k8s_node["_prefix"]}"

    _master_count  = "${var._k8s_master["_count"]}"
    _master_prefix = "${var._k8s_master["_prefix"]}"

    _volume = "${var._k8s_node["_volume"]}"

    vcpu   = "${var._k8s_node["vcpu"]}"
    memory = "${var._k8s_node["memory"]}"

    ssh_keys = "${var.ssh_keys}"

    network_id = [
        "${libvirt_network.k8s.id}",
    ]
}

# vim:ts=4:sw=4:et:
