resource "azurerm_data_factory" "adf_ws" {
    name = "${var.prefix}-adf-${random_string.postfix.result}"
    location = azurerm_resource_group.etas_poc_rg.location
    resource_group_name = azurerm_resource_group.etas_poc_rg.name
    managed_virtual_network_enabled = true
    identity {
      type = "SystemAssigned"
    }
      lifecycle {
  ignore_changes = [ tags  ]
}
  
  }

resource "azurerm_data_factory_integration_runtime_azure" "adf-ir-azure" {
  name            = "ADF-IR-Azure"
  data_factory_id = azurerm_data_factory.adf_ws.id
  location        = azurerm_resource_group.etas_poc_rg.location
  compute_type = "General"
  core_count = 8
  time_to_live_min = 20
  virtual_network_enabled = true
  
}



resource "azurerm_data_factory_linked_service_azure_blob_storage" "adf-ls_datalake" {
  name = "LS-Datalake-Storage"
  data_factory_id = azurerm_data_factory.adf_ws.id
  use_managed_identity = true
  service_endpoint = azurerm_storage_account.etas_sa.primary_blob_endpoint
  storage_kind = "StorageV2"
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.adf-ir-azure.name
  depends_on = [
    azurerm_data_factory_integration_runtime_azure.adf-ir-azure
  ]
}


