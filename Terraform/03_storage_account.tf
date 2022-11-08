
# Storage Account with VNET binding and Private Endpoint

resource "azurerm_storage_account" "etas_sa" {
  name                     = "${var.prefix}sa${random_string.postfix.result}"
  location                 = azurerm_resource_group.etas_poc_rg.location
  resource_group_name      = azurerm_resource_group.etas_poc_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  is_hns_enabled = true
  lifecycle {
  ignore_changes = [ tags  ]
}
}

# Virtual Network & Firewall configuration

resource "azurerm_storage_account_network_rules" "firewall_rules" {
  storage_account_id = azurerm_storage_account.etas_sa.id 

  default_action             = "Deny"
  ip_rules                   = [var.ip_range]
  virtual_network_subnet_ids = virtual_network_subnet_ids = [azurerm_subnet.backend_subnet.id, azurerm_subnet.frontend_subnet.id, azurerm_subnet.adbprv_subnet.id, azurerm_subnet.adbpub_subnet.id ]
  bypass                     = ["AzureServices"]

  # Set network policies after Workspace has been created (will create File Share Datastore properly)

}

# DNS Zones

resource "azurerm_private_dns_zone" "sa_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
    lifecycle {
  ignore_changes = [ tags  ]
}
}

resource "azurerm_private_dns_zone" "sa_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
    lifecycle {
  ignore_changes = [ tags  ]
}
}

resource "azurerm_private_dns_zone" "sa_zone_data_lake" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
    lifecycle {
  ignore_changes = [ tags  ]
}
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_blob_link" {
  name                  = "${random_string.postfix.result}_link_blob"
  resource_group_name   = azurerm_resource_group.etas_poc_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_blob.name
  virtual_network_id    = azurerm_virtual_network.etas_vnet.id
    lifecycle {
  ignore_changes = [ tags  ]
}
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_file_link" {
  name                  = "${random_string.postfix.result}_link_file"
  resource_group_name   = azurerm_resource_group.etas_poc_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_file.name
  virtual_network_id    = azurerm_virtual_network.etas_vnet.id
    lifecycle {
  ignore_changes = [ tags  ]
}
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_dfs_link" {
  name                  = "${random_string.postfix.result}_link_dfs"
  resource_group_name   = azurerm_resource_group.etas_poc_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_data_lake.name
  virtual_network_id    = azurerm_virtual_network.etas_vnet.id
    lifecycle {
  ignore_changes = [ tags  ]
}
}


# Private Endpoint configuration

resource "azurerm_private_endpoint" "sa_pe_blob" {
  name                = "${var.prefix}-sa-pe-blob-${random_string.postfix.result}"
  location            = azurerm_resource_group.etas_poc_rg.location
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  subnet_id           = azurerm_subnet.backend_subnet.id
  lifecycle {
  ignore_changes = [ tags  ]
}
  private_service_connection {
    name                           = "${var.prefix}-sa-psc-blob-${random_string.postfix.result}"
    private_connection_resource_id = azurerm_storage_account.etas_sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_blob.id]
  }
}

resource "azurerm_private_endpoint" "sa_pe_file" {
  name                = "${var.prefix}-sa-pe-file-${random_string.postfix.result}"
  location            = azurerm_resource_group.etas_poc_rg.location
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  subnet_id           = azurerm_subnet.backend_subnet.id
  lifecycle {
  ignore_changes = [ tags  ]
}
  private_service_connection {
    name                           = "${var.prefix}-sa-psc-file-${random_string.postfix.result}"
    private_connection_resource_id = azurerm_storage_account.etas_sa.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_file.id]
  }
}


resource "azurerm_private_endpoint" "sa_pe_data_lake" {
  name                = "${var.prefix}-sa-pe-dfs-${random_string.postfix.result}"
  location            = azurerm_resource_group.etas_poc_rg.location
  resource_group_name = azurerm_resource_group.etas_poc_rg.name
  subnet_id           = azurerm_subnet.backend_subnet.id
  lifecycle {
  ignore_changes = [ tags  ]
}
  private_service_connection {
    name                           = "${var.prefix}-sa-psc-dfs-${random_string.postfix.result}"
    private_connection_resource_id = azurerm_storage_account.etas_sa.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-dfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_data_lake.id]
  }
}

# Role assignment for Data Factory -> Storage Blob Data Contributor

resource "azurerm_role_assignment" "adf2rsg" {
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = azurerm_data_factory.adf_ws.identity[0].principal_id
  scope                 = "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}/resourceGroups/${azurerm_resource_group.etas_poc_rg.name}"
  depends_on = [
    azurerm_data_factory.adf_ws
  ]
}



#Create containers and datalake paths
#Container
resource "azurerm_storage_data_lake_gen2_filesystem" "adls_container" {
  name               = "${var.usecase_name}container"
  storage_account_id = azurerm_storage_account.etas_sa.id
   depends_on = [
    azurerm_role_assignment.adf2rsg
  ]
}

#Landing_zone

resource "azurerm_storage_data_lake_gen2_path" "Landing_Zone" {
  path               = "00_LANDING_ZONE/usecases"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.adls_container.name
  storage_account_id = azurerm_storage_account.etas_sa.id
  resource           = "directory"
 depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.adls_container
  ]
}



#Raw_Path
resource "azurerm_storage_data_lake_gen2_path" "Raw_Path_Systems" {
  path               = "01_RAW/systems"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.adls_container.name
  storage_account_id = azurerm_storage_account.etas_sa.id
  resource           = "directory"
 depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.adls_container
  ]
}

resource "azurerm_storage_data_lake_gen2_path" "Raw_Path_Flat" {
  path               = "01_RAW/flat_files"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.adls_container.name
  storage_account_id = azurerm_storage_account.etas_sa.id
  resource           = "directory"
 depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.adls_container
  ]
}


#Transformed_Path
resource "azurerm_storage_data_lake_gen2_path" "Transformed_Path" {
  path               = "02_TANSFORMATION"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.adls_container.name
  storage_account_id = azurerm_storage_account.etas_sa.id
  resource           = "directory"
 depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.adls_container
  ]
}

#Serving_Path
resource "azurerm_storage_data_lake_gen2_path" "Serving_Path" {
  path               = "03_SERVING"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.adls_container.name
  storage_account_id = azurerm_storage_account.etas_sa.id
  resource           = "directory"
 depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.adls_container
  ]
}
