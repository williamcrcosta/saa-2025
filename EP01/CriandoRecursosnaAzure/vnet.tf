# Terraform script to create a virtual network and subnets in Azure
# This script creates a virtual network with one subnet
resource "azurerm_virtual_network" "vnet-saa" {
  name                = "vnet-saa"
  location            = azurerm_resource_group.rg-saa.location
  resource_group_name = azurerm_resource_group.rg-saa.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "sub-saa" {
  name                 = "sub-saa"
  resource_group_name  = azurerm_resource_group.rg-saa.name
  virtual_network_name = azurerm_virtual_network.vnet-saa.name
  address_prefixes     = ["10.0.1.0/24"]
}
