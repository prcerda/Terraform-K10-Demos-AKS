# Define Terraform provider
terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.94.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4"   
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    } 
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.12"   
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
    }
  }
  provider_meta "google" {
  module_name = "blueprints/terraform/terraform-google-kubernetes-engine/v31.0.0"
  }
}

provider "htpasswd" {
}

resource "htpasswd_password" "hash" {
  password = var.admin_password
}

# Configure the Azure provider 01
provider "azurerm" { 
  features {}  
}

provider "helm" {
  alias = "aks01"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias = "aks01"
    host                   = azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.hol-cluster01.kube_config.0.cluster_ca_certificate)
}

# Configure the Azure provider 02
provider "helm" {
  alias = "aks02"
  kubernetes {
    host                   = azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  alias = "aks02"
    host                   = azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.hol-cluster02.kube_config.0.cluster_ca_certificate)
}