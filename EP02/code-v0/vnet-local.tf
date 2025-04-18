# Terraform script to create a virtual network and subnets in Azure
# This script creates a virtual network with two subnets, a route table, and a NAT gateway.
resource "azurerm_virtual_network" "vnet-local" {
  name                = "vnet-local"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "sub-app" {
  name                 = "sub-app"
  resource_group_name  = azurerm_resource_group.rg-local.name
  virtual_network_name = azurerm_virtual_network.vnet-local.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sub-db" {
  name                 = "sub-db"
  resource_group_name  = azurerm_resource_group.rg-local.name
  virtual_network_name = azurerm_virtual_network.vnet-local.name
  address_prefixes     = ["10.0.2.0/24"]
}