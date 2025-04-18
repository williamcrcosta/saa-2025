data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

/* resource "azurerm_app_service_plan" "wc-aps-prd-uks-001" {
  name                = "wc-aps-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  kind                = "Windows"
  sku {
    tier     = "Standard"
    size     = "1"
    capacity = 1
  }
  tags = local.tags
} */

resource "azurerm_service_plan" "wc-aps-prd-uks-001" {
  name                = "wc-aps-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  os_type             = "Windows"
  sku_name            = "S1"
  tags                = local.tags
}

/* resource "azurerm_service_plan" "wc-aps-dev-uks-001" {
  name                         = "wc-aps-dev-uks-001"
  location                     = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name          = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  os_type                      = "Windows"
  sku_name                     = "P1v2"
  tags                         = local.tags
  zone_balancing_enabled       = true
  maximum_elastic_worker_count = 3
} */

/* data "azurerm_windows_web_app" "wcappsaaprd" {
  name                = "wcappsaaprd"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
} */

data "azurerm_subnet" "wc-snet-prd-itg-uks-001" {
  name                 = "wc-snet-prd-itg-uks-001"
  resource_group_name  = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  virtual_network_name = "wc-vnet-prd-uks-001"
}

// Cria a conexão de integração com a VNET
/* resource "azurerm_app_service_virtual_network_swift_connection" "wc-vnet-integration-prd" {
  app_service_id = data.azurerm_windows_web_app.example.id
  subnet_id      = data.azurerm_subnet.wc-snet-prd-itg-uks-001.id
}
 */