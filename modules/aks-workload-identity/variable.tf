variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the identity will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aks_oidc_issuer_url" {
  description = "AKS cluster OIDC issuer URL"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the service account exists"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account_name" {
  description = "Kubernetes service account name that will use this identity"
  type        = string
}

variable "role_assignments" {
  description = "List of role assignments to grant to the identity"
  type = list(object({
    scope                = string
    role_definition_name = string
  }))
  default = []
}