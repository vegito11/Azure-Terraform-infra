include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../resource-group"]
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//networking"
}

inputs = {
  service = run_cmd("basename", "${get_terragrunt_dir()}")
}