output "name" {
  description = "The resource name of the virtual network."
  value       = module.vnet.name
}

/*output "resource" {
  description = "The virtual network resource."
  value       = module.vnet.resource
}

output "subnets" {
  description = "Information about the subnets created in the module."
  value = module.vnet.subnets
}*/

output "resource_id" {
  description = "The resource ID of the virtual network."
  value       = module.vnet.resource_id
}

output "subnets" {
  description = "Information about the subnets created in the module."
  value = {
    for k, v in module.vnet.subnets : k => {
      name             = v.name
      address_prefixes = compact(v.resource.body.properties.addressPrefixes)
      resource_id      = v.resource_id
    } if v.resource_id != null
  }
}