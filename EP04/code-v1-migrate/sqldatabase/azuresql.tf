
# Database SQL Server sendo utilizada na estrutura da SAA - 2025

resource "azurerm_mssql_server" "wc-srv-sql-prd-uks-001" {
  name                          = "wc-srv-sql-prd-uks-001"
  resource_group_name           = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  location                      = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  version                       = "12.0"
  administrator_login           = "adminsql"
  administrator_login_password  = "" // Senha do SQL Server
  public_network_access_enabled = false
  tags                          = local.tags
}

resource "azurerm_mssql_database" "saa-database" {
  name                 = "saa-database"
  server_id            = azurerm_mssql_server.wc-srv-sql-prd-uks-001.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = 2
  read_scale           = false
  sku_name             = "S0"
  zone_redundant       = false
  tags                 = local.tags
  storage_account_type = "Local"
  geo_backup_enabled   = false
}


# Database SQL Server sendo utilizada na estrutura da SAA - 2025
# Private Endpoint Configuration SQL Database

resource "azurerm_private_endpoint" "wc-pvt-sql-prd-uks-001" {
  name = "wc-pvt-sql-prd-uks-001"

  resource_group_name           = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  location                      = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  subnet_id                     = azurerm_subnet.wc-snet-pvt-prd-uks-001.id
  custom_network_interface_name = "wc-pvt-nic-sql-prd-uks-001"
  tags                          = local.tags

  private_service_connection {
    name                           = "pvt-sql-prd-uks-001-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.wc-srv-sql-prd-uks-001.id

    is_manual_connection = false
    subresource_names    = ["sqlServer"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private-dns-zone-database.id]
  }
}

data "azurerm_resource_group" "wc-rg-dr-cnc-001" {
  name = "wc-rg-dr-cnc-001"
}



