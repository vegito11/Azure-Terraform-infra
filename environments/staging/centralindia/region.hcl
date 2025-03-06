locals {
  # Detect the operating system
  region_name        = "centralindia"
  ostype             = run_cmd("bash", "-c", "echo $OSTYPE")
  region_folder_name = local.ostype == "cygwin" || local.ostype == "msys" ? run_cmd("basename", run_cmd("cygpath", "-u", run_cmd("pwd"))) : run_cmd("basename", "${get_terragrunt_dir()}")
}