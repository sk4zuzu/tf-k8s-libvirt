
resource "template_dir" "remote-exec" {
    source_dir      = "${path.module}/remote-exec/"
    destination_dir = "${path.root}/.cache/${var._prefix}/remote-exec/"
    vars {
        _MASTER_COUNT  = "${var._master_count}"
        _MASTER_PREFIX = "${var._master_prefix}"
    }
}

# vim:ts=4:sw=4:et:
