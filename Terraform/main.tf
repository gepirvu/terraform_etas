# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Azure provide configuration

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
 # backend "azurerm" {
 #   resource_group_name  = "netowrking-gp-rg"
 #   storage_account_name = "datahubstg"
 #   container_name       = "datahub"
 #   key                  = "tf-state/devEKZ"
 # }
}


provider "azurerm" {
  subscription_id = var.SUBSCRIPTION_ID
  client_id       = var.SP_CLIENT_ID
  client_secret   = var.SP_CLIENT_SECRET
  tenant_id       = var.SP_TENANT_ID
  features {}
}



data "azurerm_client_config" "current" {}

data "azurerm_subscription" "subscription" {
}
