resource "azurerm_virtual_network" "wc-vnet-prd-uks-001" {
  name                = "wc-vnet-prd-uks-001"
  location            = azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = azurerm_resource_group.wc-rg-prd-uks-001.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "wc-snet-prd-uks-001" {
  name                 = "wc-snet-prd-uks-001"
  resource_group_name  = azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name = azurerm_virtual_network.wc-vnet-prd-uks-001.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name = azurerm_virtual_network.wc-vnet-prd-uks-001.name
  address_prefixes     = ["192.168.2.0/24"]
}

# Subnet VNET Integration
resource "azurerm_subnet" "wc-snet-prd-itg-uks-001" {
  name                 = "wc-snet-prd-itg-uks-001"
  resource_group_name  = azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name = azurerm_virtual_network.wc-vnet-prd-uks-001.name
  address_prefixes     = ["192.168.3.0/24"]
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
