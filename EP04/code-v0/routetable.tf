resource "azurerm_route_table" "rt-sub-fw" {
  name                = "rt-sub-fw"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg-local.name
  tags                = local.tags
}

resource "azurerm_subnet_route_table_association" "rt-sub-fw-association" {
  subnet_id      = azurerm_subnet.sub-fw.id
  route_table_id = azurerm_route_table.rt-sub-fw.id
}

resource "azurerm_route" "route-fw" {
  name                   = "route-fw"
  resource_group_name    = data.azurerm_resource_group.rg-local.name
  route_table_name       = azurerm_route_table.rt-sub-fw.name
  address_prefix         = "192.168.0.0/16"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_windows_virtual_machine.vm-fw.private_ip_address
}