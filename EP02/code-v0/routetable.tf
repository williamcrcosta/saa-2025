resource "azurerm_route_table" "rt-sub-app-db" {
  name                = "rt-sub-app"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
}

resource "azurerm_subnet_route_table_association" "sub-app-rt-sub-app" {
  subnet_id      = azurerm_subnet.sub-app.id
  route_table_id = azurerm_route_table.rt-sub-app-db.id
}

resource "azurerm_subnet_route_table_association" "sub-db-rt-sub-app" {
  subnet_id      = azurerm_subnet.sub-db.id
  route_table_id = azurerm_route_table.rt-sub-app-db.id
}

# Voce vai precisar desta UDR abaixo quando for estabelecer a comunicação com os outros ambientes.
/* resource "azurerm_route" "udr-sub-app-db" {
  name                   = "udr-azure"
  resource_group_name    = azurerm_resource_group.rg-local.name
  route_table_name       = azurerm_route_table.rt-sub-app-db.name
  address_prefix         = "192.168.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.azurerm_virtual_machine.vm-fw.private_ip_address
}
 */
/*
data "azurerm_virtual_machine" "vm-fw" {
  name                = "vm-fw"
  resource_group_name = azurerm_resource_group.rg-local.name
}
 */