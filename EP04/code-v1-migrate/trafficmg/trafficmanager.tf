data "azurerm_resource_group" "wc-rg-prd-uks-001" {
  name = "wc-rg-prd-uks-001"
}

resource "azurerm_traffic_manager_profile" "wc-tfm-prd-001" {
  name                   = "wc-tfm-prd-001"
  resource_group_name    = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  traffic_routing_method = "Priority"
  tags                   = local.tags
  traffic_view_enabled   = true

  dns_config {
    relative_name = "wc-tfm-prd-001"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

data "azurerm_windows_web_app" "wcappsaaprd" {
  name                = "wcappsaaprd"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

resource "azurerm_traffic_manager_azure_endpoint" "end-webp-prd-001" {
  name                 = "end-webp-prd-001"
  profile_id           = azurerm_traffic_manager_profile.wc-tfm-prd-001.id
  always_serve_enabled = false
  weight               = 1
  target_resource_id   = data.azurerm_windows_web_app.wcappsaaprd.id
}


data "azurerm_resource_group" "wc-rg-dr-cnc-001" {
  name = "wc-rg-dr-cnc-001"
}

data "azurerm_windows_web_app" "wcappsaadr" {
  name                = "wcappsaadr"
  resource_group_name = data.azurerm_resource_group.wc-rg-dr-cnc-001.name
}

resource "azurerm_traffic_manager_azure_endpoint" "end-webp-dr-001" {
  name                 = "end-webp-dr-001"
  profile_id           = azurerm_traffic_manager_profile.wc-tfm-prd-001.id
  always_serve_enabled = false
  weight               = 1
  target_resource_id   = data.azurerm_windows_web_app.wcappsaadr.id
}
