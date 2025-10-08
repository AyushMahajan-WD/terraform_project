output "public_ip_addresses" {

  value = {
    nat_gateway_ip = azurerm_public_ip.public_ip["pip-1"].ip_address
    pub_load_lb_ip = azurerm_public_ip.public_ip["pip-2"].ip_address
    jumpserver_ip  = azurerm_public_ip.public_ip["pip-3"].ip_address
  }

}

output "linux_vm_private_ip_addresses" {
  value = {
    for vm_name, nic in azurerm_network_interface.linux_vm_nic :
    vm_name => nic.ip_configuration[0].private_ip_address
  }
}

output "resource_ids" {
  value = {
    resource_group_id = azurerm_resource_group.terraform_rg.id
    vnet_id           = azurerm_virtual_network.terraform_vnet.id
    pub_subnet_id     = azurerm_subnet.terraform_pub_subnet_1.id
    pvt_subnet_id     = azurerm_subnet.terraform_pvt_subnet_1.id
    nat_gw_id         = azurerm_nat_gateway.terraform_nat_gw.id
    lb_id             = azurerm_lb.terraform_pub_lb.id
  }
}

output "ssh_pvt_key" {
  value = {
    linux_vm_ssh_key   = tls_private_key.linux_vm_ssh_key.private_key_pem,
    jumpserver_ssh_key = tls_private_key.jumpserver_linux_vm_ssh_key.private_key_pem
  }
  sensitive = true
}


