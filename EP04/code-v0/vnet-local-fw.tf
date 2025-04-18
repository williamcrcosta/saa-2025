

# Terraform script to create a virtual network and subnets in Azure
# This script creates a virtual network with two subnets, a route table, and a NAT gateway.
resource "azurerm_virtual_network" "vnet-local-fw" {
  name                = "vnet-local-fw"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-local.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "sub-fw" {
  name                 = "sub-fw"
  resource_group_name  = data.azurerm_resource_group.rg-local.name
  virtual_network_name = azurerm_virtual_network.vnet-local-fw.name
  address_prefixes     = ["10.1.1.0/24"]
}

data "azurerm_virtual_network" "vnet-local" {
  name                = "vnet-local"
  resource_group_name = data.azurerm_resource_group.rg-local.name
}

resource "azurerm_virtual_network_peering" "vnet-local-fw-to-vnet-local" {
  name                         = "vnet-local-fw-to-vnet-local"
  resource_group_name          = data.azurerm_resource_group.rg-local.name
  virtual_network_name         = azurerm_virtual_network.vnet-local-fw.name
  remote_virtual_network_id    = data.azurerm_virtual_network.vnet-local.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vnet-local-to-vnet-local-fw" {
  name                         = "vnet-local-to-vnet-local-fw"
  resource_group_name          = data.azurerm_resource_group.rg-local.name
  virtual_network_name         = data.azurerm_virtual_network.vnet-local.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-local-fw.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

