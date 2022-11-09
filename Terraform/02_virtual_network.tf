# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Virtual Network definition

resource "azurerm_virtual_network" "etas_vnet" {
  name                = "${var.prefix}-vnet-${random_string.postfix.result}"
  address_space       = ["100.68.194.0/24"]
  location            = azurerm_resource_group.etas_poc_rg.location
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  lifecycle {
  ignore_changes = [ tags  ]
}
}


#Create backend_subnet and frontend_subnet
resource "azurerm_subnet" "backend_subnet" {
  name                 = "${var.prefix}-backend-subnet-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["100.68.194.128/27"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "frontend_subnet" {
  name                 = "${var.prefix}-frontend-subnet-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["100.68.194.160/27"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage","Microsoft.Sql"]
  enforce_private_link_service_network_policies = false
  enforce_private_link_endpoint_network_policies = false
}

#Create network security groups for databricks

resource "azurerm_network_security_group" "privatensg" {
  name = "${var.prefix}-nsgprv-${random_string.postfix.result}"

  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  location            = azurerm_resource_group.etas_poc_rg.location
}

resource "azurerm_subnet_network_security_group_association" "privateasoc" {
  subnet_id                 = azurerm_subnet.adbprv_subnet.id
  network_security_group_id = azurerm_network_security_group.privatensg.id
}


resource "azurerm_network_security_group" "publicnsg" {
  name = "${var.prefix}-nsgpub-${random_string.postfix.result}"

  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  location            = azurerm_resource_group.etas_poc_rg.location
}

resource "azurerm_subnet_network_security_group_association" "publicasoc" {
  subnet_id                 = azurerm_subnet.adbpub_subnet.id
  network_security_group_id = azurerm_network_security_group.publicnsg.id
}


#Create Databricks dedicated subnets. These will be managed by Databricks with service delegation

resource "azurerm_subnet" "adbpub_subnet" {
  name                 = "${var.prefix}-adbpub-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["100.68.194.64/26"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage","Microsoft.Sql"]
  enforce_private_link_service_network_policies = false
  enforce_private_link_endpoint_network_policies = false

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "adbprv_subnet" {
  name                 = "${var.prefix}-adbprv-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["100.68.194.192/26"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage","Microsoft.Sql"]
  enforce_private_link_service_network_policies = false
  enforce_private_link_endpoint_network_policies = false

    delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}