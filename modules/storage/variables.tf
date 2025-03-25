
variable "envname" {
  type        = string
  description = "enviroment for which this resource belongs to - used as prefix in naming"
  default     = "testing"
}

variable "companyname" {
  type        = string
  description = "companyname for which this resource belongs to - used as prefix in naming"
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
(Optional) The location/region where the virtual network is created. Changing this forces a new resource to be created. 
DESCRIPTION
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
(Required) The name of the resource group where the resources will be deployed. 
DESCRIPTION
}
