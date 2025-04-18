resource "azurerm_resource_group" "rg-local" {
  name     = "rg-local"
  location = "eastus"
  tags     = local.tags
}