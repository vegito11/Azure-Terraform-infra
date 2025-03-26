resource "azurerm_storage_account" "storage" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.location
  name                     = "${var.companyname}0${var.envname}0app"
  resource_group_name      = var.resource_group_name
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.companyname}app"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_key_vault" "kv" {
  name                = "${var.companyname}0${var.envname}0secret"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "standard"
  tenant_id           = var.tenant_id
  enable_rbac_authorization = true
}