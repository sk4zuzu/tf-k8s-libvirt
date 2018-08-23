
network = [{
    subnet = "10.11.12.0/24"
}]

ssh_keys = [{
    key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCq6DrqEDYg0e4aD0mrFZNAofYmt+7KiVkO0tpkzQYPLuwbhZTZOGiEc2xulWd9epcjSqhmZTiqOlNSYjYiiXy3WefObqe1Cncs7FY/qDSIjcXx0XhC78ZR/MVhP1RpwSI+JY1tEXxs4RR1lt1LX5OsRI97h5RbmkfheXuQz7RZ5Q=="
}]

_enable_provisioning = true

_k8s_master = {
    _count  = 3
    _prefix = "dev-master"
    _volume = "../../packer/k8s-libvirt/ubuntu-16.04-server-cloudimg-amd64-disk1.img/qcow2"
    vcpu    = 1
    memory  = "1024"
}

_k8s_node = {
    _count  = 2
    _prefix = "dev-node"
    _volume = "../../packer/k8s-libvirt/ubuntu-16.04-server-cloudimg-amd64-disk1.img/qcow2"
    vcpu    = 2
    memory  = "2048"
}

# vim:ts=4:sw=4:et:
