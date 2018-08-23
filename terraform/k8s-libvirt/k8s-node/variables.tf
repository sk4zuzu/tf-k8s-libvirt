
variable "_enable_provisioning" {
    type = "string"
}

variable "_depends_on" {
    type = "list"
}

variable "_count" {
    type = "string"
}

variable "_prefix" {
    type = "string"
}

variable "_master_count" {
    type = "string"
}

variable "_master_prefix" {
    type = "string"
}

variable "_volume" {
    type = "string"
}

variable "vcpu" {
    type = "string"
}

variable "memory" {
    type = "string"
}

variable "ssh_keys" {
    type = "list"
}

variable "network_id" {
    type = "list"
}

# vim:ts=4:sw=4:et:
