# Azure Machine Learning - Private Link for most services deployment

This Terraform template deploys the following architecture:

It includes:

* Resource group
* Virtual network and 4 subnets, 2 dedicated for Databricks
* Azure Storage Account - Data Lake with VNET binding (using Service Endpoints) and Private Link for Blob and File
* Azure Key Vault with VNET binding (using Service Endpoints) and Private Link + Secrets
* Azure Data Factory + Linked Services
* Azure Databricks + Cluster

## Instructions




