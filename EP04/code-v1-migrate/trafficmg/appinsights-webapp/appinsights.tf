data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

resource "azurerm_log_analytics_workspace" "wc-lwk-prd-uks-001" {
  name                = "wc-lwk-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "wc-api-prd-uks-001" {
  name                = "wc-api-prd-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  workspace_id        = azurerm_log_analytics_workspace.wc-lwk-prd-uks-001.id
  application_type    = "web"
}

output "instrumentation_key" {
  value     = azurerm_application_insights.wc-api-prd-uks-001.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.wc-api-prd-uks-001.app_id
}


####### DR

data "azurerm_resource_group" "wc-rg-dr-cnc-001" {
  name = "wc-rg-dr-cnc-001"
}

resource "azurerm_log_analytics_workspace" "wc-lwk-dr-cnc-001" {
  name                = "wc-lwk-dr-cnc-001"
  location            = data.azurerm_resource_group.wc-rg-dr-cnc-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-dr-cnc-001.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "wc-api-dr-cnc-001" {
  name                = "wc-api-dr-cnc-001"
  location            = data.azurerm_resource_group.wc-rg-dr-cnc-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-dr-cnc-001.name
  workspace_id        = azurerm_log_analytics_workspace.wc-lwk-dr-cnc-001.id
  application_type    = "web"
}

output "instrumentation_key_dr" {
  value     = azurerm_application_insights.wc-api-dr-cnc-001.instrumentation_key
  sensitive = true
}

output "app_id_dr" {
  value = azurerm_application_insights.wc-api-dr-cnc-001.app_id
}