
variable "network" {
    type = "list"
}

variable "ssh_keys" {
    type = "list"
}

variable "_enable_provisioning" {
    type = "string"
}

variable "_k8s_master" {
    type = "map"
}

variable "_k8s_node" {
    type = "map"
}

# vim:ts=4:sw=4:et:
