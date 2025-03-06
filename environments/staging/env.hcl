locals {

  envname             = "staging"
  resource_group_name = "staging"
  enable_telemetry    = false
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

  akssubnet = "stgsubnet1"

  api_server_authorized_ip_ranges = ["103.159.152.100/32"]

  control_plane_k8s_version = "1.32.0"
  worker_node_k8s_version   = "1.32.0"

  additional_node_pools = {
    "UserRegularPool" = {
      name                  = "reglrstg" ## max name should be 8 char only lowercase , number
      orchestrator_version  = "1.31.0"
      enable_auto_scaling   = true
      zones                 = ["1", "3"]
      vm_size               = "standard_b2als_v2"
      os_disk_size_gb       = 15
      os_disk_type          = "Managed"
      priority              = "Regular"
      eviction_policy       = null
      min_count             = 1
      max_count             = 2
      max_pods              = 50
      create_before_destroy = false
    }
  }

}