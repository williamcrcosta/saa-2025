data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

resource "azurerm_load_test" "wc-lt-app-prd-001" {
  name                = "wc-lt-app-prd-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  tags                = local.tags
}

####### DR

data "azurerm_resource_group" "wc-rg-dr-cnc-001" {
  name = "wc-rg-dr-cnc-001"
}

resource "azurerm_load_test" "wc-lt-app-dr-001" {
  name                = "wc-lt-app-dr-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  tags                = local.tags
}