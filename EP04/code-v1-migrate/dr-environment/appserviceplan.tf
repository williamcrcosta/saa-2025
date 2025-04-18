
resource "azurerm_service_plan" "wc-aps-dr-cnc-001" {
  name                = "wc-aps-dr-cnc-001"
  location            = azurerm_resource_group.wc-rg-dr-cnc-001.location
  resource_group_name = azurerm_resource_group.wc-rg-dr-cnc-001.name
  os_type             = "Windows"
  sku_name            = "S1"
  tags                = local.tags
}

data "azurerm_windows_web_app" "wcappsaadr" {
  name                = "wcappsaadr"
  resource_group_name = azurerm_resource_group.wc-rg-dr-cnc-001.name
}

resource "azurerm_app_service_virtual_network_swift_connection" "wc-vnet-integration-dr" {
  app_service_id = data.azurerm_windows_web_app.wcappsaadr.id
  subnet_id      = azurerm_subnet.wc-snet-itg-dr-cnc-001.id
}


data "azurerm_private_dns_zone" "private-dns-zone-database" {
  name = "privatelink.database.windows.net"
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-dns-zone-database-link" {
  name                  = "wc-vnet-dr-cnc-001-link"
  resource_group_name   = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  private_dns_zone_name = data.azurerm_private_dns_zone.private-dns-zone-database.name
  virtual_network_id    = azurerm_virtual_network.wc-vnet-dr-cnc-001.id
}

data "azurerm_network_security_group" "wc-nsg-snet-pvt-prd-uks-001" {
  name                = "wc-nsg-snet-pvt-prd-uks-001"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

