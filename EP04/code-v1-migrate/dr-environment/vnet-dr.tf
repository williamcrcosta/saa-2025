resource "azurerm_virtual_network" "wc-vnet-dr-cnc-001" {
  name                = "wc-vnet-dr-cnc-001"
  location            = azurerm_resource_group.wc-rg-dr-cnc-001.location
  resource_group_name = azurerm_resource_group.wc-rg-dr-cnc-001.name
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "wc-snet-pvt-dr-uks-001" {
  name                 = "wc-snet-pvt-dr-uks-001"
  resource_group_name  = azurerm_resource_group.wc-rg-dr-cnc-001.name
  virtual_network_name = azurerm_virtual_network.wc-vnet-dr-cnc-001.name
  address_prefixes     = ["172.16.10.0/24"]
}

# Subnet VNET Integration
resource "azurerm_subnet" "wc-snet-itg-dr-cnc-001" {
  name                 = "wc-snet-itg-dr-cnc-001"
  resource_group_name  = azurerm_resource_group.wc-rg-dr-cnc-001.name
  virtual_network_name = azurerm_virtual_network.wc-vnet-dr-cnc-001.name
  address_prefixes     = ["172.16.2.0/24"]
  delegation {
    name = "Microsoft.Web/serverFarms"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

data "azurerm_virtual_network" "wc-vnet-prd-uks-001" {
  name                = "wc-vnet-prd-uks-001"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

resource "azurerm_virtual_network_peering" "vnet-dr-001-to-vnet-prd-001" {
  name                         = "vnet-dr-001-to-vnet-prd-001"
  resource_group_name          = azurerm_resource_group.wc-rg-dr-cnc-001.name
  virtual_network_name         = azurerm_virtual_network.wc-vnet-dr-cnc-001.name
  remote_virtual_network_id    = data.azurerm_virtual_network.wc-vnet-prd-uks-001.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vnet-prd-001-to-vnet-dr-001" {
  name                         = "vnet-prd-001-to-vnet-dr-001"
  resource_group_name          = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name         = data.azurerm_virtual_network.wc-vnet-prd-uks-001.name
  remote_virtual_network_id    = azurerm_virtual_network.wc-vnet-dr-cnc-001.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}