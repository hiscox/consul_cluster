output "load_balancer_ip" {
  value = "${azurerm_lb.load_balancer.private_ip_address}"
}

output "encryption_key" {
  value = "${random_id.encrypt.b64_std}"
}
