include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../_env/vnet.hcl"
}

inputs = {
  location = include.root.inputs.region_name
}