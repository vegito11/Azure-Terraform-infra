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