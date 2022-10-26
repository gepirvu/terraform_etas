# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Location of the environment, default is West Europe
variable "location" {
  default = "westeurope"
}

#Usecase prefix used in naming convention for uniqueness, default is ebspp
variable "prefix" {
  type = string
  default = "etas"
}

#Usecase postfix used in naming convention for uniqueness
resource "random_string" "postfix" {
  length = 6
  special = false
  upper = false
}

# Resource group name
variable "resource_group" {
  default = "etas_bosch_poc_rg"
}


variable ip_range {
  type = string
  default = "85.216.51.235"
}


#Insert your Subscription_id
variable "SUBSCRIPTION_ID" {
  type = string
  default = "..."
}

#Insert your Client_id
variable "SP_CLIENT_ID" {
  type = string
  default = "..."
}

#Insert Client_Secret
variable "SP_CLIENT_SECRET" {
  type = string
  default = "..."
}

#Insert Tenant_id
variable "SP_TENANT_ID" {
  type = string
  default = "..."
}

