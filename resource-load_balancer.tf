resource "azurerm_lb" "load_balancer" {
  name                = "${local.name}"
  location            = "${azurerm_resource_group.resource_group.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  frontend_ip_configuration {
    name                          = "${local.name}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "${local.name}"
}

resource "azurerm_lb_probe" "probe" {
  count               = "${length(local.ports)}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "${element(keys(local.ports), count.index)}"
  port                = "${element(values(local.ports), count.index)}"
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "rule_tcp" {
  count                          = "${length(local.ports)}"
  resource_group_name            = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "${element(keys(local.ports), count.index)}tcp"
  protocol                       = "Tcp"
  frontend_port                  = "${element(values(local.ports), count.index)}"
  backend_port                   = "${element(values(local.ports), count.index)}"
  frontend_ip_configuration_name = "${local.name}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_address_pool.id}"
  probe_id                       = "${element(azurerm_lb_probe.probe.*.id, count.index)}"
  enable_floating_ip             = false
  load_distribution              = "Default"
}

resource "azurerm_lb_rule" "rule_udp" {
  count                          = "${length(local.ports)}"
  resource_group_name            = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "${element(keys(local.ports), count.index)}udp"
  protocol                       = "Udp"
  frontend_port                  = "${element(values(local.ports), count.index)}"
  backend_port                   = "${element(values(local.ports), count.index)}"
  frontend_ip_configuration_name = "${local.name}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_address_pool.id}"
  probe_id                       = "${element(azurerm_lb_probe.probe.*.id, count.index)}"
  enable_floating_ip             = false
  load_distribution              = "Default"
}
