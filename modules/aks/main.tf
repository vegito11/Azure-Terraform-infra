locals {
  default_name          = "${var.envname}-aks"
  resolved_cluster_name = (var.cluster_name != "" && var.cluster_name != null) ? var.cluster_name : local.default_name
  # Ensure only one var.envname at the start
  normalized_cluster_name = replace(local.resolved_cluster_name, "^${var.envname}-*", "")

  additional_node_pools = {
    for pool_name, pool_config in var.additional_node_pools :
    pool_name => merge(
      pool_config,
      {
        orchestrator_version = pool_config["orchestrator_version"] != null ? pool_config["orchestrator_version"] : var.aks_agent_config.worker_node_k8s_version
        vnet_subnet_id       = var.aks_default_subnet_id
      }
    )
  }
}

resource "azurerm_user_assigned_identity" "aks" {
  location            = var.location
  name                = "${local.normalized_cluster_name}-identity"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

data "azurerm_kubernetes_service_versions" "latest_version" {
  location        = var.location
  include_preview = false
}

/*data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}*/


data "azurerm_client_config" "current" {}

/*resource "azuread_group" "admin_group" {
  display_name     = "${local.normalized_cluster_name}-admin"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}*/

module "aks" {

  source  = "Azure/aks/azurerm"
  version = "9.4.1"

  cluster_name                = local.normalized_cluster_name
  prefix                      = local.normalized_cluster_name
  resource_group_name         = var.resource_group_name
  temporary_name_for_rotation = "poolrot"

  kubernetes_version = var.aks_agent_config.control_plane_k8s_version != "" ? var.aks_agent_config.control_plane_k8s_version : data.azurerm_kubernetes_service_versions.latest_version.versions[0]
  sku_tier           = "Standard"
  vnet_subnet_id     = var.aks_default_subnet_id
  # private_dns_zone_id         = data.azurerm_private_dns_zone.azmk8s.id

  only_critical_addons_enabled = true
  enable_auto_scaling          = false
  agents_size                  = var.aks_agent_config.system_pool_vm_size
  agents_availability_zones    = var.aks_agent_config.system_pool_availability_zones
  agents_count                 = var.aks_agent_config.system_pool_size_count
  agents_max_pods              = 100
  agents_pool_name             = substr(replace(replace("systempool-${local.normalized_cluster_name}", "-", ""), "_", ""), 0, 12)

  node_pools = merge(
    {
      "UserSpotPool" = {
        name                 = substr(replace(replace("spot-${local.normalized_cluster_name}", "-", ""), "_", ""), 0, 8)
        orchestrator_version = var.aks_agent_config.worker_node_k8s_version
        # node_taints           = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
        enable_auto_scaling   = true
        zones                 = var.aks_agent_config.system_pool_availability_zones
        vm_size               = var.aks_agent_config.spot_pool_vm_size
        os_disk_size_gb       = var.aks_agent_config.os_disk_size_gb
        os_disk_type          = "Ephemeral"
        priority              = "Spot"
        eviction_policy       = "Delete"
        min_count             = 0
        max_count             = 2
        max_pods              = 100
        vnet_subnet_id        = var.aks_default_subnet_id
        create_before_destroy = true
      }
  }, local.additional_node_pools)

  azure_policy_enabled            = true
  log_analytics_workspace_enabled = false

  identity_ids                    = [azurerm_user_assigned_identity.aks.id]
  identity_type                   = "UserAssigned"
  local_account_disabled          = false
  private_cluster_enabled         = false
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  # api_server_authorized_ip_ranges   = [jsondecode(data.http.public_ip.response_body).ip]
  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true
  enable_host_encryption            = false
  rbac_aad_tenant_id                = data.azurerm_client_config.current.tenant_id
  rbac_aad_admin_group_object_ids   = [var.admin_group_obid]
  # rbac_aad_admin_group_object_ids   = [azuread_group.admin_group.object_id]
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_plugin             = "azure"
  network_policy             = "azure"
  create_role_assignments_for_application_gateway = var.create_brown_field_application_gateway || var.create_brown_field_application_gateway
  brown_field_application_gateway_for_ingress = var.create_brown_field_application_gateway ? {
    id        = var.aks_apppgw_id
    subnet_id = var.aks_apppgw_subnet_id
  } : null

  net_profile_service_cidr   = var.aks_agent_config.services_cidr
  net_profile_dns_service_ip = var.aks_agent_config.dns_service_ip
  node_os_channel_upgrade    = "NodeImage"
  os_disk_size_gb            = var.aks_agent_config.os_disk_size_gb



  maintenance_window = {
    allowed = [
      {
        day   = "Sunday"
        hours = [22, 23]
      },
    ]
  }
  maintenance_window_node_os = {
    frequency  = "Daily"
    interval   = 1
    start_time = "07:00"
    utc_offset = "+01:00"
    duration   = 16
  }

  tags = var.tags
}