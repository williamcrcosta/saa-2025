# Obtém informações sobre o grupo de recursos existente "wc-rg-prd-uks-001"
data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

# Obtém informações sobre a rede virtual existente "wc-vnet-prd-uks-001" no grupo de recursos especificado
data "azurerm_virtual_network" "wc-vnet-prd-uks-001" {
  name                = "wc-vnet-prd-uks-001"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

# Obtém informações sobre o "GatewaySubnet" na rede virtual e grupo de recursos especificados
data "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.wc-vnet-prd-uks-001.name
  resource_group_name  = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

# Cria um endereço IP público para o gateway da rede virtual
resource "azurerm_public_ip" "wc-pip-prd-vng-uks-001" {
  name                = "wc-pip-prd-vng-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "wcprdvng001"
  tags                = local.tags
}

# Cria um gateway de rede virtual para a rede virtual especificada
resource "azurerm_virtual_network_gateway" "wc-vng-prd-uks-001" {
  name                = "wc-vng-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  tags                = local.tags

  active_active = false
  enable_bgp    = false
  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = "VpnGw2"
  generation    = "Generation2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.wc-pip-prd-vng-uks-001.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.GatewaySubnet.id
  }
}

# Obtém informações sobre o grupo de recursos existente "rg-local"
data "azurerm_resource_group" "rg-local" {
  name = "rg-local"
}

# Obtém informações sobre o endereço IP público existente "vm-fw-pip" no grupo de recursos "rg-local"
data "azurerm_public_ip" "vm-fw-pip" {
  name                = "vm-fw-pip"
  resource_group_name = data.azurerm_resource_group.rg-local.name
}

# Cria um gateway de rede local para representar a rede on-premises
resource "azurerm_local_network_gateway" "wc-lng-prd-uks-001" {
  name                = "wc-lng-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name

  gateway_address = data.azurerm_public_ip.vm-fw-pip.ip_address

  address_space = [
    "10.0.0.0/16",
    "10.1.0.0/16"
  ]
  tags = local.tags
}

# Cria uma conexão entre o gateway de rede virtual e o gateway de rede local
resource "azurerm_virtual_network_gateway_connection" "wc-con-vng-prd-uks-001" {
  name                       = "wc-con-vng-prd-uks-001"
  location                   = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name        = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.wc-vng-prd-uks-001.id
  local_network_gateway_id   = azurerm_local_network_gateway.wc-lng-prd-uks-001.id
  shared_key                 = "" # Especifique a mesma chave compartilhada em ambos os lados da conexão
  tags                       = local.tags
}