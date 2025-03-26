terraform {
  source = "${get_parent_terragrunt_dir()}/../../modules//aks-workload-identity"
}

dependency "rg" {
  config_path = "../../resource-group"
}

dependency "aks" {
  config_path = "../../aks"
  # skip_outputs  = true
  mock_outputs = {
    aks_oidc_issuer_url = "https://aks-oidc.example.com"
  }
  # mock_outputs_allowed_terraform_commands = ["plan", "validate", "state"]

}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = merge(
  local.env_vars.locals,
  {
    resource_group_name = dependency.rg.outputs.default_resource_group_name
    location            = local.region_vars.locals.region_name
    aks_oidc_issuer_url = dependency.aks.outputs.oidc_issuer_url

  }
)