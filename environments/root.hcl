locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  client_secret                          = get_env("ARM_CLIENT_SECRET")
  arn_tenant_id                          = get_env("ARM_TENANT_ID")
  deployment_storage_resource_group_name = get_env("MGMT_RG_NAME", "management")
  deployment_region                      = local.region_vars.locals.region_name
  use_remote_state                       = get_env("USE_REMOTE_STATE", "true")
  current_component                      = run_cmd("basename", get_terragrunt_dir())
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an Blob Storage container
remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = local.use_remote_state == "true" ? {
    resource_group_name  = get_env("MGMT_RG_NAME", "management")
    storage_account_name = get_env("STATE_STORAGE_ACC_NAME", "omkar0infra0bucket")
    container_name       = get_env("STATE_CONTAINER_NAME", "terraform-state-${local.arn_tenant_id}")
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    } : {
    path = "${get_parent_terragrunt_dir()}/local-state/${local.region_folder_name}-${local.current_component}-terraform.tfstate"
  }

}

terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands = get_terraform_commands_that_need_locking()

    arguments = [
      "-lock-timeout=20m"
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.env_vars.locals,
  local.region_vars.locals,
  {
    client_secret         = local.client_secret
    admin_group_object_id = get_env("TF_admin_group_object_id")
  }
)
