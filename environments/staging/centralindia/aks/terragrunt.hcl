include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../_env/aks.hcl"
}

inputs = {
  location         = include.root.inputs.region_name
  admin_group_obid = include.root.inputs.admin_group_object_id
}