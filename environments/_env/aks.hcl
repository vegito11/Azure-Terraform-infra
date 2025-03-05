terraform {
  source = "${get_parent_terragrunt_dir()}/../../modules//aks"
}

dependency "rg" {
  config_path = "../resource-group"
  # skip_outputs = true
}

dependency "vnet" {
  config_path = "../networking"
  # skip_outputs = true
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = merge(
  local.env_vars.locals,
  {
    resource_group_name = dependency.rg.outputs.default_resource_group_name
    resource_group_id = dependency.rg.outputs.default_resource_group_id
    
    location = local.region_vars.locals.region_name
    name    = "${local.env_vars.locals.envname}-vnet"
    aks_default_subnet_id = dependency.vnet.outputs.subnets[local.env_vars.locals.akssubnet].resource_id
    aks_agent_config = {
      control_plane_k8s_version              = "1.32.0"
      worker_node_k8s_version                = "1.32.0"
      os_disk_size_gb                        = 20
      system_pool_vm_size                    = "Standard_K8S2_v1"
      system_pool_size_count                 = 2
      system_pool_availability_zones         = ["2", "3"]
      services_cidr                          = "192.169.0.0/16"
      dns_service_ip                         = "192.169.0.10"
    }
  }
)


# https://github.com/Azure/terraform-azurerm-aks/blob/main/examples/multiple_node_pools/main.tf