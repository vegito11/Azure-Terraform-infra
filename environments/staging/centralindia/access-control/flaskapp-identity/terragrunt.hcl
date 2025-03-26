include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "identity" {
  path = "${get_terragrunt_dir()}/../../../../_env/identity.hcl"
  #   expose         = true
  #   merge_strategy = "deep"
}

dependency "storage" {
  config_path = "../../storage"
}

locals {
  subscription_id     = include.root.inputs.subscription_id
  resource_group_name = include.root.inputs.resource_group_name
}

inputs = {
  kubernetes_service_account_name = "flaskapp"
  identity_name                   = "${include.root.inputs.envname}-flaskapp-podidentity"
  role_assignments = [
    {
      role_definition_name = "Storage Blob Data Contributor"
      scope                = "${dependency.storage.outputs.storage_account_id}"
      # scope = "/subscriptions/${local.subscription_id}/resourceGroups/${dependency.rg.outputs.default_resource_group_name}/providers/Microsoft.Storage/storageAccounts/test"
    },
    {
      role_definition_name = "Key Vault Secrets User"
      scope                = "${dependency.storage.outputs.secret_id}"
    },
    {
      role_definition_name = "Key Vault Secrets Officer"
      scope                = "${dependency.storage.outputs.secret_id}"
    }
  ]
}