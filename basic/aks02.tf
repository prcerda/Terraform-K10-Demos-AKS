# Create a resource group
resource "azurerm_resource_group" "demo_rgroup02" {
  name     = "rg-${var.cluster_name02}-${local.saString}"
  location = var.region02
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }    
}

# VNET Network
resource "azurerm_virtual_network" "vnet_network02" {
  name                = "vnet-${var.cluster_name02}-${local.saString}"
  address_space       = ["10.60.0.0/16"]
  location            = var.region02
  resource_group_name = azurerm_resource_group.demo_rgroup02.name
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }       
}


#Subnet
resource "azurerm_subnet" "subnet-k10-demo02" {
  name                 = "subnet-${var.cluster_name02}-${local.saString}"
  resource_group_name  = azurerm_resource_group.demo_rgroup02.name
  virtual_network_name = azurerm_virtual_network.vnet_network02.name
  address_prefixes       = ["10.60.1.0/24"]
}

## Private Link

# Create User Assigned Identity
resource "azurerm_user_assigned_identity" "aks-demo-id02" {
  location            = azurerm_resource_group.demo_rgroup02.location
  name                = "aks-id-${var.cluster_name02}-${local.saString}"
  resource_group_name = azurerm_resource_group.demo_rgroup02.name
  tags = {
    owner = var.owner_aks
    activity = var.activity
  } 
}

## Create AKS Cluster

resource "azurerm_kubernetes_cluster" "aks-cluster02" {
  name                = "aks-${var.cluster_name02}-${local.saString}"
  location            = azurerm_resource_group.demo_rgroup02.location
  resource_group_name = azurerm_resource_group.demo_rgroup02.name
  dns_prefix          = "dns-${var.cluster_name02}-${local.saString}"

  default_node_pool {
      name            = "default"
      node_count      = var.aks_num_nodes
      vm_size         = "${var.aks_instance_type}"
      os_disk_size_gb = 30
  }

  identity {
      type = "SystemAssigned"
  }
  tags = {
    owner = var.owner_aks
    activity = var.activity
  }     
}

# Storage Class Region 2
resource "kubernetes_storage_class" "storage_class_02" {
provider   = kubernetes.aks02
depends_on = [azurerm_kubernetes_cluster.aks-cluster02]
  metadata {
    name = "aks02-storage-class"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "disk.csi.azure.com"
  allow_volume_expansion = "true"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
  parameters = {
    skuName = "StandardSSD_LRS"
  }
}

## AKS Disk VolumeSnapshotClass
resource "helm_release" "az-volumesnapclass02" {
  provider   = helm.aks02
  depends_on = [kubernetes_storage_class.storage_class_02]
  name = "az-volumesnapclass"
  create_namespace = true

  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "az-volumesnapclass"  
}


