terraform {
  source = "${get_parent_terragrunt_dir()}/../../modules//networking"
  # source = "tfr:///Azure/avm-res-network-virtualnetwork/azurerm?version=0.7.1"
}

dependency "rg" {
  config_path = "../resource-group"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

}

inputs = merge(
  local.env_vars.locals,
  {
    resource_group_name = dependency.rg.outputs.default_resource_group_name
    location = local.region_vars.locals.region_name
    name    = "${local.env_vars.locals.envname}-vnet"
  }
)

# https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork/blob/main/examples/complete_azurerm_v4/main.tf

# https://github.com/Azure/terraform-azurerm-aks/blob/main/examples/multiple_node_pools/main.tf