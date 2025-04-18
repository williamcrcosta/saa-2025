data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

resource "azurerm_private_dns_zone" "private-dns-zone-database" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatedns-link-vnet-prod-uks" {
  name                  = "wc-vnet-prd-uks-001-link"
  resource_group_name   = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-database.name
  virtual_network_id    = data.azurerm_virtual_network.wc-vnet-prd-uks-001.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatedns-link-vnet-local" {
  name                  = "vnet-local-link"
  resource_group_name   = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-database.name
  virtual_network_id    = data.azurerm_virtual_network.vnet-local.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatedns-link-vnet-local-fw" {
  name                  = "vnet-local-fw-link"
  resource_group_name   = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  private_dns_zone_name = azurerm_private_dns_zone.private-dns-zone-database.name
  virtual_network_id    = data.azurerm_virtual_network.vnet-local-fw.id
  registration_enabled  = false
  tags                  = local.tags
}