include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "identity" {
  path = "${get_terragrunt_dir()}/../../../../_env/identity.hcl"
#   expose         = true
#   merge_strategy = "deep"
}

locals {
  subscription_id       = include.root.inputs.subscription_id
  resource_group_name   = include.root.inputs.resource_group_name
}

inputs = {
  location                        = include.root.inputs.region_name
  admin_group_obid                = include.root.inputs.admin_group_object_id
  kubernetes_service_account_name = "flaskapp"
  identity_name                   = "${include.root.inputs.envname}-flaskapp-podidentity"
  role_assignments = [
    {
      role_definition_name  = "Storage Blob Data Contributor"
      scope = "/subscriptions/${local.subscription_id}/resourceGroups/${dependency.rg.outputs.default_resource_group_name}/providers/Microsoft.Storage/storageAccounts/test"
      # scope = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/test"
    }
  ]
}