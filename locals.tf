locals {
  name = "${var.name_prefix}${random_string.random_name.result}"

  ports = {
    rpc     = 8300
    serflan = 8301
    serfwan = 8302
    http    = 8500
  }

  consul_local_config = {
    datacenter = "${var.location}"
    log_level  = "INFO"
    retry_join = "${azurerm_network_interface.network_interface.*.private_ip_address}"
    encrypt    = "${random_id.encrypt.b64_std}"
  }

  tags = "${merge(
    var.tags,
    map(
      "environment", var.environment,
      "application", var.application,
      "service", "consul",
      "consul_version", var.consul_version
    )
  )}"
}
