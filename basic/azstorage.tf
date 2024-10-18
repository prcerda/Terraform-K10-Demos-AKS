# Create storage account AKS01
resource "azurerm_storage_account" "repository01" {
  name                        = "${var.cluster_name01}blob${local.saString}"
  resource_group_name         = azurerm_resource_group.demo_rgroup01.name
  location                    = var.region01
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }        
}

resource "azurerm_storage_container" "container01" {
  name                  = "k10"
  storage_account_name  = azurerm_storage_account.repository01.name
  container_access_type = "private"
}


# Create storage account AKS02
resource "azurerm_storage_account" "repository02" {
  name                        = "${var.cluster_name02}blob${local.saString}"
  resource_group_name         = azurerm_resource_group.demo_rgroup02.name
  location                    = var.region02
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }        
}

resource "azurerm_storage_container" "container02" {
  name                  = "k10"
  storage_account_name  = azurerm_storage_account.repository02.name
  container_access_type = "private"
}


# Create storage account Global
resource "azurerm_storage_account" "repository_global" {
  name                        = "globalblob${local.saString}"
  resource_group_name         = azurerm_resource_group.demo_rgroup01.name
  location                    = var.region01
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }        
}

resource "azurerm_storage_container" "container_global" {
  name                  = "k10"
  storage_account_name  = azurerm_storage_account.repository_global.name
  container_access_type = "private"
}