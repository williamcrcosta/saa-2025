# Obtém o IP público da máquina local
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Network Security Group (NSG) para a aplicação
resource "azurerm_network_security_group" "nsg-app" {
  name                = "nsg-app"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  tags                = local.tags
}

# Associa o NSG da aplicação à subnet correspondente
resource "azurerm_subnet_network_security_group_association" "ass-nsg-app" {
  subnet_id                 = azurerm_subnet.sub-app.id
  network_security_group_id = azurerm_network_security_group.nsg-app.id
}

# Regra de segurança para permitir RDP no NSG da aplicação
resource "azurerm_network_security_rule" "nsg-app-rdp" {
  name                        = "nsg-app-rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = chomp(data.http.myip.response_body) # IP da máquina local
  destination_address_prefix  = azurerm_windows_virtual_machine.vm-app.private_ip_address
  resource_group_name         = azurerm_resource_group.rg-local.name
  network_security_group_name = azurerm_network_security_group.nsg-app.name
}

# Network Security Group (NSG) para o banco de dados
resource "azurerm_network_security_group" "nsg-db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  tags                = local.tags
}

# Associa o NSG do banco de dados à subnet correspondente
resource "azurerm_subnet_network_security_group_association" "ass-nsg-db" {
  subnet_id                 = azurerm_subnet.sub-db.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}

# Regra de segurança para permitir RDP no NSG do banco de dados
resource "azurerm_network_security_rule" "nsg-db-rdp" {
  name                        = "nsg-db-rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = chomp(data.http.myip.response_body) # IP da máquina local
  destination_address_prefix  = "*"                                 # Permite acesso a qualquer destino
  resource_group_name         = azurerm_resource_group.rg-local.name
  network_security_group_name = azurerm_network_security_group.nsg-db.name
}