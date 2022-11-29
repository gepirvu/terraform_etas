


resource "azurerm_databricks_workspace" "adb_workspace" {
  resource_group_name           = var.resource_group
  location                      = var.location
  name                          = "${var.prefix}-adb-${random_string.postfix.result}"
  sku                           = "premium"
  
  
  custom_parameters {
    virtual_network_id = azurerm_virtual_network.etas_vnet.id
    private_subnet_name = azurerm_subnet.adbprv_subnet.name
    public_subnet_name = azurerm_subnet.adbpub_subnet.name
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.publicasoc.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.privateasoc.id
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.publicasoc,
    azurerm_subnet_network_security_group_association.privateasoc
  ]

}


resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "${var.prefix}-adbcluster-${random_string.postfix.result}"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 20
  autoscale {
    min_workers = 2
    max_workers = 3
  }
 
 depends_on = [azurerm_databricks_workspace.adb_workspace]
}


resource "databricks_token" "pat" {
  provider = databricks
  comment  = "Terraform Provisioning"
  // 100 day token -  lifetime_seconds = 8640000
  depends_on = [azurerm_databricks_workspace.adb_workspace]
}

