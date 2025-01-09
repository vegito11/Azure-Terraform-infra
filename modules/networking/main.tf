resource "azurerm_route_table" "this" {
  location            = var.location
  name                = "${var.envname}-route-table"
  resource_group_name = var.resource_group_name
}

# Creating a DDoS Protection Plan in the specified location.
resource "azurerm_network_ddos_protection_plan" "this" {
  location            = var.location
  name                = "${var.envname}-ddos-protection-plan"
  resource_group_name = var.resource_group_name
}

#Creating a NAT Gateway in the specified location.
resource "azurerm_nat_gateway" "this" {
  location            = var.location
  name                = "${var.envname}-NAT"
  resource_group_name = var.resource_group_name
}

# Fetching the public IP address of the Terraform executor used for NSG
data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}

resource "azurerm_network_security_group" "https" {
  location            = var.location
  name                = "${var.envname}-NSG"
  resource_group_name = var.resource_group_name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPS"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
    source_port_range          = "*"
  }
}

resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  name                = "${var.envname}-user-identity"
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = var.location
  name                     = "${var.envname}0appstorage"
  resource_group_name      = var.resource_group_name
}

resource "azurerm_subnet_service_endpoint_storage_policy" "this" {
  location            = var.location
  name                = "sep-${var.envname}"
  resource_group_name = var.resource_group_name

  definition {
    name = "${var.envname}-se-storage-policy"
    service_resources = [
      var.resource_group_name,
      azurerm_storage_account.this.id
    ]
    description = "${var.envname} service endpoint storage policy"
    service     = "Microsoft.Storage"
  }
}

module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "${var.envname}-vnet"

  address_space = var.address_space

  dns_servers = {
    dns_servers = ["8.8.8.8"]
  }

  ddos_protection_plan = {
    id = azurerm_network_ddos_protection_plan.this.id
    # due to resource cost
    enable = false
  }

  role_assignments = {
    role1 = {
      principal_id               = azurerm_user_assigned_identity.this.principal_id
      role_definition_id_or_name = "Contributor"
    }
  }

  enable_vm_protection = true

  encryption = {
    enabled = true
    #enforcement = "DropUnencrypted"  # NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/AllowDropUnecryptedVnet
    enforcement = "AllowUnencrypted"
  }

  flow_timeout_in_minutes = 30

  # subnets = local.subnets
  subnets = {
    for subnet_name, subnet_config in var.subnets : subnet_name => merge(
      subnet_config,
      {

         nat_gateway = lookup(var.subnet_nat_gateway, subnet_name, false) && (!contains(keys(subnet_config), "nat_gateway") || subnet_config["nat_gateway"] == null) ? {
            id = azurerm_nat_gateway.this.id
         } : lookup(subnet_config, "nat_gateway", null)

          network_security_group = lookup(var.subnet_network_security_group, subnet_name, false) && (!contains(keys(subnet_config), "network_security_group") || subnet_config["network_security_group"] == null) ? {
            id = azurerm_network_security_group.https.id
          } : lookup(subnet_config, "network_security_group", null)

          route_table = lookup(var.subnet_route_table, subnet_name, false) && (!contains(keys(subnet_config), "route_table") || subnet_config["route_table"] == null) ? {
            id = azurerm_route_table.this.id
          } : lookup(subnet_config, "route_table", null)

          service_endpoints = lookup(var.subnet_service_endpoints, subnet_name, []) != []  ? var.subnet_service_endpoints[subnet_name] : lookup(subnet_config, "service_endpoints", null)

          service_endpoint_policies = lookup(var.subnet_service_endpoint_policies, subnet_name, false) && (!contains(keys(subnet_config), "service_endpoint_policies") || subnet_config["service_endpoint_policies"] == null) ? {
            policy1 = {
              id = azurerm_subnet_service_endpoint_storage_policy.this.id
            }
          } : lookup(subnet_config, "service_endpoint_policies", null)

          network_security_group = lookup(var.subnet_network_security_group, subnet_name, false) && (!contains(keys(subnet_config), "network_security_group") || subnet_config["network_security_group"] == null) ? {
            id = azurerm_network_security_group.https.id
          } : lookup(subnet_config, "network_security_group", null)

          delegation = lookup(var.subnet_delegations, subnet_name, []) != []  ? var.subnet_delegations[subnet_name] : lookup(subnet_config, "delegation", null)

          role_assignments = lookup(var.subnet_role_assignments, subnet_name, false) && (!contains(keys(subnet_config), "role_assignments") || subnet_config["role_assignments"] == null) ? {
            role1 = {
              principal_id               = azurerm_user_assigned_identity.this.principal_id
              role_definition_id_or_name = "Contributor"
            }
          } : lookup(subnet_config, "role_assignments", null)
      }
    )
  }

}