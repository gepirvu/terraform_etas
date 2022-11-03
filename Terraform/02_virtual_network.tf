# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Virtual Network definition

resource "azurerm_virtual_network" "etas_vnet" {
  name                = "${var.prefix}-vnet-${random_string.postfix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.etas_poc_rg.location
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  lifecycle {
  ignore_changes = [ tags  ]
}
}

resource "azurerm_subnet" "backend_subnet" {
  name                 = "${var.prefix}-backend-subnet-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["10.0.1.0/27"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "frontend_subnet" {
  name                 = "${var.prefix}-frontend-subnet-${random_string.postfix.result}"
  resource_group_name  = azurerm_resource_group.etas_poc_rg.name
  virtual_network_name = azurerm_virtual_network.etas_vnet.name
  address_prefixes     = ["10.0.2.0/27"]
  service_endpoints    = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage","Microsoft.Sql"]
  enforce_private_link_service_network_policies = false
  enforce_private_link_endpoint_network_policies = false
}
