data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.vnet_resource_group_name}"
}

resource "random_id" "encrypt" {
  byte_length = 16
}

data "template_file" "consulservice" {
  count    = "${var.vm_count}"
  template = "${file("${path.module}/consul.service.tpl")}"

  vars {
    consul_local_config = "${jsonencode(local.consul_local_config)}"

    #jsonencode converts ints to strings, so pass bootstrap_expect as a command line parameter instead
    bootstrap_expect = "${var.vm_count}"
    consul_version   = "${var.consul_version}"
    node             = "${local.name}-${format("%02d", count.index)}"
  }
}

data "ignition_systemd_unit" "systemd_unit" {
  count   = "${var.vm_count}"
  name    = "consul.service"
  enabled = true
  content = "${element(data.template_file.consulservice.*.rendered, count.index)}"
}

data "ignition_config" "config" {
  count = "${var.vm_count}"

  systemd = [
    "${element(data.ignition_systemd_unit.systemd_unit.*.id, count.index)}",
  ]
}
