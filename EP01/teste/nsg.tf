# Pega o ip da sua maquina local
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# NSG
resource "azurerm_network_security_group" "nsg-saa" {
  name                = "nsg-saa"
  location            = azurerm_resource_group.rg-saa.location
  resource_group_name = azurerm_resource_group.rg-saa.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "ass-nsg-saa" {
  subnet_id                 = azurerm_subnet.sub-saa.id
  network_security_group_id = azurerm_network_security_group.nsg-saa.id
}

resource "azurerm_network_security_rule" "ruleRDP-nsg-saa" {
  name                        = "ruleRDP-nsg-saa"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = chomp(data.http.myip.response_body)
  destination_address_prefix  = azurerm_windows_virtual_machine.vm-saa.private_ip_address
  resource_group_name         = azurerm_resource_group.rg-saa.name
  network_security_group_name = azurerm_network_security_group.nsg-saa.name
}

resource "azurerm_network_security_rule" "ruleHTTP-nsg-saa" {
  name                        = "ruleHTTP-nsg-saa"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_windows_virtual_machine.vm-saa.private_ip_address
  resource_group_name         = azurerm_resource_group.rg-saa.name
  network_security_group_name = azurerm_network_security_group.nsg-saa.name
}