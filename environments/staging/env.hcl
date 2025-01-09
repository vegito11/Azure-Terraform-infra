locals {
    
    envname = "staging"
    resource_group_name = "staging"
    address_space       = ["11.0.0.0/16"]
    subnets = {
      "subnet1" = {
        name             = "staging-subnet-1"
        address_prefixes = ["11.0.224.4/20"]
      }
      "subnet2" = {
        name             = "staging-subnet-2"
        address_prefixes = ["11.0.240.4/20"]
      }
    }    
}