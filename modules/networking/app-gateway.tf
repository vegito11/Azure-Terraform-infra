locals {
  backend_address_pool_name      = try("${module.vnet.name}-beap", "")
  frontend_ip_configuration_name = try("${module.vnet.name}-feip", "")
  frontend_port_name             = try("${module.vnet.name}-feport", "")
  http_setting_name              = try("${module.vnet.name}-be-htst", "")
  listener_name                  = try("${module.vnet.name}-httplstn", "")
  request_routing_rule_name      = try("${module.vnet.name}-rqrt", "")
}

resource "azurerm_public_ip" "pip" {
  count = var.create_brown_field_application_gateway ? 1 : 0
  allocation_method   = "Static"
  location            = var.location
  name                = "${var.envname}-appgw-pip"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  count = var.create_brown_field_application_gateway ? 1 : 0

  location = var.location
  #checkov:skip=CKV_AZURE_120:We don't need the WAF for this simple example
  name                = "${var.envname}-ingress"
  resource_group_name = var.resource_group_name

  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip[0].id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = module.vnet.subnets[var.appgw_subnet].resource_id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.listener_name
    protocol                       = "Http"
  }
  request_routing_rule {
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
    ]
  }
}
