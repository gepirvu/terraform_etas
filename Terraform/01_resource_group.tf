# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

resource "azurerm_resource_group" "etas_poc_rg" {
  name     = var.resource_group
  location = var.location

  tags                 = {
           "ApplicationID"    = "ETAS POC" 
           "ApplicationOwner" = "ETAS" 
           "CostCenter"       = "12345" 
        }

lifecycle {
  ignore_changes = [ tags  ]
}
  

}