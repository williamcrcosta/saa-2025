resource "azurerm_resource_group" "wc-rg-dr-cnc-001" {
  name     = "wc-rg-dr-cnc-001"
  location = "Canada Central"
  tags     = local.tags
}