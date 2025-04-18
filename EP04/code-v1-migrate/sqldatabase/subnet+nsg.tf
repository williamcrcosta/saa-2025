data "azurerm_virtual_network" "wc-vnet-prd-uks-001" {
  name                = "wc-vnet-prd-uks-001"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

resource "azurerm_subnet" "wc-snet-pvt-prd-uks-001" {
  name                 = "wc-snet-pvt-prd-uks-001"
  resource_group_name  = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name = data.azurerm_virtual_network.wc-vnet-prd-uks-001.name
  address_prefixes     = ["192.168.10.0/24"]
}

resource "azurerm_network_security_group" "wc-nsg-snet-pvt-prd-uks-001" {
  name                = "wc-nsg-snet-pvt-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name


  security_rule {
    name                       = "Allow-SQL-Access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes    = ["192.168.3.0/32", "172.16.2.0/24", "10.0.1.0/24"]
    destination_address_prefix = "192.168.10.5/32"
    description                = "Allow SQL access from the specified IP address"
  }
  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "wc-nsg-snet-pvt-prd-uks-assoc" {
  subnet_id                 = azurerm_subnet.wc-snet-pvt-prd-uks-001.id
  network_security_group_id = azurerm_network_security_group.wc-nsg-snet-pvt-prd-uks-001.id
}

data "azurerm_resource_group" "rg-local" {
  name = "rg-local"
}

data "azurerm_virtual_network" "vnet-local" {
  name                = "vnet-local"
  resource_group_name = data.azurerm_resource_group.rg-local.name
}

data "azurerm_virtual_network" "vnet-local-fw" {
  name                = "vnet-local-fw"
  resource_group_name = data.azurerm_resource_group.rg-local.name
}