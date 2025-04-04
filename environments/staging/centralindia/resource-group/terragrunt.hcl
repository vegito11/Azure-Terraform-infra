include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//resource-group"
  # source = "git::https://gitlab-ci-bott:${get_env("TF_PRIVATE_REPO_PAT", "")}@gitlab.com/vegito11/iac-modules.git/resource-group//."
}

# inputs = include.root.inputs