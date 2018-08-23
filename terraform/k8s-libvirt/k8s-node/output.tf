
data "null_data_source" "done" {
    depends_on = [ "null_resource.k8s-node" ]
    inputs = {
        done = "${uuid()}"
    }
}

output "done" {
    depends_on = [ "null_data_source.done" ]
    value = "${data.null_data_source.done.outputs["done"]}"
}

# vim:ts=4:sw=4:et:
