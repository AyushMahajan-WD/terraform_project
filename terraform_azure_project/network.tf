resource "azurerm_virtual_network" "terraform_vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = var.location
  address_space       = var.address_space["vnet_as"]
  subnet              = []
  tags = {
    project = "terraform"
  }
}

resource "azurerm_subnet" "terraform_pub_subnet_1" {
  name                 = var.subnet_name[0]
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = var.address_space["subnet_1"]
}

resource "azurerm_subnet" "terraform_pvt_subnet_1" {
  name                 = var.subnet_name[1]
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = var.address_space["subnet_2"]
}

# Nat Gateway on public subnet
resource "azurerm_nat_gateway" "terraform_nat_gw" {
  name                = local.terraform_nat_gw_name
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  sku_name            = "Standard"
  tags = {
    project = "terraform"
  }
}

resource "azurerm_subnet_nat_gateway_association" "terraform_subnet_nat_gw_assoc" {
  subnet_id      = azurerm_subnet.terraform_pvt_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.terraform_nat_gw.id
}

resource "azurerm_nat_gateway_public_ip_association" "terraform_nat_gw_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.terraform_nat_gw.id
  public_ip_address_id = azurerm_public_ip.public_ip["pip-1"].id
}

# Load Balancer Public Subnet
resource "azurerm_lb" "terraform_pub_lb" {
  name                = var.lb_name
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "fe-ip-config-${var.lb_name}"
    public_ip_address_id = azurerm_public_ip.public_ip["pip-2"].id
  }
  tags = {
    project = "terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "terraform_pub_lb_backend_pool" {
  loadbalancer_id = azurerm_lb.terraform_pub_lb.id
  name            = local.terraform_pub_lb_backend_pool_name


}

resource "azurerm_network_interface_backend_address_pool_association" "linux_vm_nic_lb_backend_pool_assoc" {
  for_each                = (azurerm_network_interface.linux_vm_nic)
  network_interface_id    = each.value.id
  ip_configuration_name   = azurerm_network_interface.linux_vm_nic[each.key].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.terraform_pub_lb_backend_pool.id
}

resource "azurerm_lb_rule" "terraform_pub_lb_rule" {
  loadbalancer_id                = azurerm_lb.terraform_pub_lb.id
  name                           = "${azurerm_lb.terraform_pub_lb.name}-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.terraform_pub_lb.frontend_ip_configuration[0].name
}

#Network secuirty Group
resource "azurerm_network_security_group" "terraform_pvt_subnet_nsg" {
  name                = var.terraform_pvt_subnet_nsg_name
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  security_rule {
    name                       = "ssh_inbound_to_pvts"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_subnet.terraform_pub_subnet_1.address_prefixes[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "lb_to_pvts"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  tags = {
    project = "terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "terraform_pvt_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.terraform_pvt_subnet_1.id
  network_security_group_id = azurerm_network_security_group.terraform_pvt_subnet_nsg.id
}

resource "azurerm_network_security_group" "jumpserver_nsg" {
  name                = var.jumpserver_nsg_name
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name

  security_rule {
    name                       = "ssh_inbound_to_pvts"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.terraform_pvt_subnet_1.address_prefixes[0]
  }
  tags = {
    project = "terraform"
  }
}

resource "azurerm_network_interface_security_group_association" "jumpserver_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.jumpserver_linux_vm_nic.id
  network_security_group_id = azurerm_network_security_group.jumpserver_nsg.id
}



#public ips
resource "azurerm_public_ip" "public_ip" {
  for_each            = toset(local.public_ip_name)
  name                = each.value
  location            = azurerm_virtual_network.terraform_vnet.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    project = "terraform"
  }

  # pip_1 = terraform-nat-gw
  # pip_2 = terraform-pub-lb
  # pip_3 = jumpserver-linux-vm
}



