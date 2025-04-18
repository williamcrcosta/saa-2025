resource "azurerm_resource_group" "rg-saa" {
  name     = "rg-saa"
  location = "eastus"
  tags     = local.tags
}