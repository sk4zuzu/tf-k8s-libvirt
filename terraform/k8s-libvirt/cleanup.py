#!/usr/bin/env python2

import sys
import hcl, json
import os, glob

from subprocess import check_call, check_output, CalledProcessError


def _env():
    def tf_workspace(*args):
        command = ["terraform", "workspace"]
        command.extend(args)
        return check_output(command, shell=False)  # raises CalledProcessError

    env = tf_workspace("show").splitlines()[0].strip()

    return env


def _config():
    with open("environment/{:s}.tfvars".format(_env())) as stream:
        config = hcl.load(stream)

    return config


def _cleanup(config):
    def virsh(*args):
        command = ["virsh"]
        command.extend(args)
        try:
            check_call(command, shell=False)  # raises CalledProcessError
        except CalledProcessError:
            pass

    def cleanup_domain(domain):
        for k in range(1, int(config[domain]["_count"]) + 1):
            name = "{:s}{:d}".format(config[domain]["_prefix"], k)
            virsh("destroy", name)
            virsh("undefine", name, "--managed-save")
            virsh("vol-delete", "--pool=default", "{:s}".format(name))
            virsh("vol-delete", "--pool=default", "{:s}.iso".format(name))

    def cleanup_network(network):
        virsh("net-destroy", network)
        virsh("net-undefine", network)

    def cleanup_base_image(base_image):
        virsh("vol-delete", "--pool=default", base_image)

    def cleanup_tfstate():
        map(os.remove,
            glob.glob("terraform.tfstate.d/{:s}/terraform.tfstate*".format(_env()))
        )

    cleanup_domain("_k8s_master")
    cleanup_domain("_k8s_node")

    cleanup_base_image("k8s-master-qcow2")
    cleanup_base_image("k8s-node-qcow2")

    cleanup_network("k8s")

    cleanup_tfstate()


if __name__ == "__main__":
    config = _config()

    print(json.dumps(config, indent=4))

    _cleanup(config)


# vim:ts=4:sw=4:et:syn=python:
