resource "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name     = "wc-rg-prd-uks-001"
  location = "uksouth"
  tags     = local.tags
}