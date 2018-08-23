
resource "template_dir" "remote-exec" {
    source_dir      = "${path.module}/remote-exec/"
    destination_dir = "${path.root}/.cache/${var._prefix}/remote-exec/"
    vars {
        _COUNT  = "${var._count}"
        _PREFIX = "${var._prefix}"
    }
}

# vim:ts=4:sw=4:et:
