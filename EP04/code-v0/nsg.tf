# Pega o ip da sua maquina local
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_network_security_group" "nsg-fw" {
  name                = "nsg-fw"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-local.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "nsg-fw-rule-rdp" {
  name                   = "nsg-fw-rule-rdp"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "3389"
  source_address_prefix  = chomp(data.http.myip.response_body)
  destination_address_prefixes = [
    azurerm_windows_virtual_machine.vm-fw.private_ip_address,
    azurerm_windows_virtual_machine.vm-client.private_ip_address
  ]
  resource_group_name         = data.azurerm_resource_group.rg-local.name
  network_security_group_name = azurerm_network_security_group.nsg-fw.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-fw-association" {
  subnet_id                 = azurerm_subnet.sub-fw.id
  network_security_group_id = azurerm_network_security_group.nsg-fw.id
}
