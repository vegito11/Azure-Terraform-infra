output "identity_id" {
  description = "ID of the created user-assigned identity"
  value       = azurerm_user_assigned_identity.workload_identity.id
}

output "identity_principal_id" {
  description = "Principal ID of the created user-assigned identity"
  value       = azurerm_user_assigned_identity.workload_identity.principal_id
}

output "identity_client_id" {
  description = "Client ID of the created user-assigned identity"
  value       = azurerm_user_assigned_identity.workload_identity.client_id
}

output "federated_identity_id" {
  description = "ID of the federated identity credential"
  value       = azurerm_federated_identity_credential.federated_identity.id
}