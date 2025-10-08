resource "azurerm_resource_group" "terraform_rg" {
  name     = var.rg_name
  location = var.location
  tags = {
    project = "terraform"
  }
}
