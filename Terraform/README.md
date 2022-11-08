# Azure Machine Learning - Private Link for most services deployment

This Terraform template deploys the following architecture:

It includes:

* Azure Machine Learning Workspace with Private Link
* Azure Storage Account with VNET binding (using Service Endpoints) and Private Link for Blob and File
* Data Lake
* Azure Key Vault with VNET binding (using Service Endpoints) and Private Link
* Azure Container Registry
* Azure Application Insights
* Virtual Network
* Jumphost (Windows) with Bastion for easy access to the VNET
* Compute Cluster (in VNET)
* Compute Instance (in VNET)
* (Azure Kubernetes Service - disabled by default and still under development)

## Instructions




