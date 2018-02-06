resource "random_string" "random_name" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.environment}-${var.application}-consul-${var.location}"
  location = "${var.location}"
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = "${local.name}"
  location            = "${azurerm_resource_group.resource_group.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

resource "azurerm_network_security_rule" "network_security_rule" {
  count                       = "${length(local.ports)}"
  name                        = "${element(keys(local.ports), count.index)}"
  priority                    = "${count.index + 100}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "${element(values(local.ports), count.index)}"
  source_address_prefixes     = ["${data.azurerm_virtual_network.virtual_network.address_spaces}"]
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resource_group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_security_group.name}"
}

resource "azurerm_network_security_rule" "network_security_rule_load_balancer" {
  name                        = "loadbalancer"
  priority                    = 4095
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resource_group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_security_group.name}"
}

resource "azurerm_network_security_rule" "network_security_rule_deny" {
  name                        = "deny"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.resource_group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_security_group.name}"
}

resource "azurerm_network_interface" "network_interface" {
  count                     = "${var.vm_count}"
  name                      = "${local.name}-${format("%02d", count.index)}"
  location                  = "${azurerm_resource_group.resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.network_security_group.id}"

  ip_configuration {
    name                          = "${local.name}"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"

    load_balancer_backend_address_pools_ids = [
      "${azurerm_lb_backend_address_pool.backend_address_pool.id}",
    ]
  }
}

resource "azurerm_availability_set" "availability_set" {
  name                = "${local.name}"
  location            = "${azurerm_resource_group.resource_group.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  managed             = true
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${local.name}"
  location                 = "${azurerm_resource_group.resource_group.location}"
  resource_group_name      = "${azurerm_resource_group.resource_group.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "virtual_machine" {
  count                            = "${var.vm_count}"
  name                             = "${local.name}-${format("%02d", count.index)}"
  location                         = "${azurerm_resource_group.resource_group.location}"
  resource_group_name              = "${azurerm_resource_group.resource_group.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.network_interface.*.id, count.index)}"]
  availability_set_id              = "${azurerm_availability_set.availability_set.id}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  vm_size                          = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "CoreOS"
    offer     = "CoreOS"
    sku       = "Stable"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.name}-${format("%02d", count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${local.name}-${format("%02d", count.index)}"
    admin_username = "azureuser"
    admin_password = "Qwerty12345^"
    custom_data    = "${element(data.ignition_config.config.*.rendered, count.index)}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}"
  }

  tags = "${local.tags}"
}
