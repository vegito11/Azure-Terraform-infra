resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "federated_identity" {
  name                = "${var.identity_name}-federated-credential"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  subject             = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account_name}"
}

resource "azurerm_role_assignment" "identity_roles" {
  for_each             = { for idx, role in var.role_assignments : idx => role }
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}