output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_id" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  description = "The login server URL for ACR"
  value       = azurerm_container_registry.acr.login_server
}

# output "acr_admin_username" {
#   description = "The admin username for ACR"
#   value       = azurerm_container_registry.acr.admin_username
#   sensitive   = true
# }

# output "acr_admin_password" {
#   description = "The admin password for ACR"
#   value       = azurerm_container_registry.acr.admin_password
#   sensitive   = true
# }

output "storage_account_name" {
  description = "The name of the Azure Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary Blob endpoint for the storage account"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "storage_account_id" {
  description = "The id of the Azure Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "secret_id" {
  description = "The id of the Azure Keyvault secret"
  value       = azurerm_key_vault.kv.id
}