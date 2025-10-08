data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "terraform_keyvault" {
  name                        = local.terraform_keyvault_name
  location                    = azurerm_resource_group.terraform_rg.location
  resource_group_name         = azurerm_resource_group.terraform_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7

  sku_name = local.key_valult_sku

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = {
    project = "terraform"
  }
}

resource "tls_private_key" "linux_vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "jumpserver_linux_vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_key_vault_secret" "linux_vm_pvt_ssh_key_secret" {
  name         = var.linux_vm_pvt_ssh_key_name
  value        = tls_private_key.linux_vm_ssh_key.private_key_pem
  key_vault_id = azurerm_key_vault.terraform_keyvault.id
}
