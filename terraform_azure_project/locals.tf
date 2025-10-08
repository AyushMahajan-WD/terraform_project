locals {
  terraform_nat_gw_name = "terraform-pvt-subnet-nat-gw"

  terraform_vm_name = [
    for i in range(1, 4) : "terraform-vm-linux-${i}"
  ]

  public_ip_name = [
    for i in range(1, 4) : "pip-${i}"
  ]

  terraform_pub_lb_backend_pool_name = "${azurerm_lb.terraform_pub_lb.name}-backend-pool"

  linux_vm_size = "Standard_B1s"

  linux_vm_ssh_key_path = "~/.ssh/id_rsa.pub"

  linux_vm_admin_username = "adminuser"

  jumpserver_linux_vm_username = "jumpadmin"

  linux_vm_os_disk_caching = "ReadWrite"

  jumpserver_linux_vm_os_disk_caching = "ReadWrite"

  key_valult_sku = "standard"

  terraform_keyvault_name = "terraform-kv-${random_string.key_vault_random.result}"

}

resource "random_string" "key_vault_random" {
  length  = 6
  numeric = true
  special = false
  keepers = {
    key_vault_keeper = var.key_vault_keeper
  }
}
