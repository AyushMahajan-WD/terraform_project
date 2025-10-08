resource "azurerm_network_interface" "linux_vm_nic" {
  for_each            = toset(local.terraform_vm_name)
  name                = "nic-${each.value}"
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  ip_configuration {
    name                          = "ipconfig-${each.value}"
    subnet_id                     = azurerm_subnet.terraform_pvt_subnet_1.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    project = "terraform"
  }
}

resource "azurerm_network_interface" "jumpserver_linux_vm_nic" {
  name                = "nic-${var.jumpserver_linux_vm_name}"
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name


  ip_configuration {
    name                          = "ipconfig-${var.jumpserver_linux_vm_name}"
    subnet_id                     = azurerm_subnet.terraform_pub_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip["pip-3"].id
  }

  tags = {
    project = "terraform"
  }
}



#Linux backend internal VMs

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each            = toset(local.terraform_vm_name)
  name                = each.value
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_virtual_network.terraform_vnet.location
  size                = local.linux_vm_size
  admin_username      = local.linux_vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.linux_vm_nic[each.value].id,
  ]

  admin_ssh_key {
    username   = local.linux_vm_admin_username
    public_key = tls_private_key.linux_vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = local.linux_vm_os_disk_caching
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_linux_virtual_machine" "jumpserver_linux_vm" {
  name                = var.jumpserver_linux_vm_name
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_virtual_network.terraform_vnet.location
  size                = local.linux_vm_size
  admin_username      = local.jumpserver_linux_vm_username
  network_interface_ids = [
    azurerm_network_interface.jumpserver_linux_vm_nic.id
  ]

  admin_ssh_key {
    username   = local.jumpserver_linux_vm_username
    public_key = tls_private_key.jumpserver_linux_vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = local.jumpserver_linux_vm_os_disk_caching
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    project = "terraform"
  }
}
