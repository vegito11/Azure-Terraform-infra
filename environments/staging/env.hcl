locals {
    
    envname = "staging"
    resource_group_name = "staging"
    enable_telemetry = false
    address_space       = ["11.0.0.0/16"]
    subnets = {
      "stgsubnet1" = {
        name             = "staging-subnet-1"
        address_prefixes = ["11.0.224.0/20"]
      }
      "stgsubnet2" = {
        name             = "staging-subnet-2"
        address_prefixes = ["11.0.240.0/20"]
      }
    }

    akssubnet = "stgsubnet2"
    
    

}