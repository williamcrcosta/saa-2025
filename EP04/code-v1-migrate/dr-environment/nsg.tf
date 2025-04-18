# Pega o ip da sua maquina local
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_network_security_group" "wc-nsg-prd-uks-001" {
  name                = "wc-nsg-prd-uks-001"
  location            = azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = azurerm_resource_group.wc-rg-prd-uks-001.name
}

resource "azurerm_subnet_network_security_group_association" "wc-snet-prd-uks-001-assoc" {
  subnet_id                 = azurerm_subnet.wc-snet-prd-uks-001.id
  network_security_group_id = azurerm_network_security_group.wc-nsg-prd-uks-001.id
}

resource "azurerm_network_security_rule" "wc-nsg-prd-uks-001-rule-rdp" {
  name                        = "wc-nsg-prd-uks-001-rule-rdp"
  network_security_group_name = azurerm_network_security_group.wc-nsg-prd-uks-001.name
  resource_group_name         = azurerm_resource_group.wc-rg-prd-uks-001.name
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = chomp(data.http.myip.response_body)
  destination_address_prefix  = "192.168.1.4/32"
  description                 = "Allow RDP access to the subnet"
}