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

    databricks = {
      source = "databricks/databricks"
      version = "1.6.3"
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

provider "databricks" {
# alias = "created_workspace"
#   azure_workspace_resource_id = azurerm_databricks_workspace.adb_workspace.id
  host = azurerm_databricks_workspace.adb_workspace.workspace_url
}

data "databricks_node_type" "smallest" {
  local_disk = true

  depends_on = [
    azurerm_databricks_workspace.adb_workspace
  ]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [
    azurerm_databricks_workspace.adb_workspace
  ]
}


data "azurerm_client_config" "current" {}

data "azurerm_subscription" "subscription" {
}
