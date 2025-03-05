output "admin_client_certificate" {
  sensitive = true
  value     = module.aks.admin_client_certificate
}

output "admin_client_key" {
  sensitive = true
  value     = module.aks.admin_client_key
}

output "admin_cluster_ca_certificate" {
  sensitive = true
  value     = module.aks.admin_client_certificate
}

output "admin_host" {
  sensitive = true
  value     = module.aks.admin_host
}

output "admin_password" {
  description = "The `password` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. A password or token used to authenticate to the Kubernetes cluster."
  sensitive = true
  value     = module.aks.admin_password
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = module.aks.oidc_issuer_url
}

output "admin_username" {
  description = "The `username` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. A username used to authenticate to the Kubernetes cluster."
  sensitive = true
  value     = module.aks.admin_username
}

output "aks_id" {
   description = "The `azurerm_kubernetes_cluster`'s id."
  value = module.aks.aks_id
}

output "client_certificate" {
  sensitive = true
  value     = module.aks.client_certificate
}

output "client_key" {
  sensitive = true
  value     = module.aks.client_key
}

output "cluster_ca_certificate" {
  sensitive = true
  value     = module.aks.client_certificate
}

output "cluster_portal_fqdn" {
  value = module.aks.cluster_portal_fqdn
}

output "cluster_private_fqdn" {
  value = module.aks.cluster_private_fqdn
}

output "host" {
  sensitive = true
  value     = module.aks.host
}

output "kube_raw" {
  sensitive = true
  value     = module.aks.kube_config_raw
}

output "password" {
  description = "The `password` in the `azurerm_kubernetes_cluster`'s `kube_config` block. A password or token used to authenticate to the Kubernetes cluster."
  sensitive = true
  value     = module.aks.password
}

output "username" {
  description = "The `username` in the `azurerm_kubernetes_cluster`'s `kube_config` block. A username used to authenticate to the Kubernetes cluster."
  sensitive = true
  value     = module.aks.username
}