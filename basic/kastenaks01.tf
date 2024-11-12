## Kasten namespace
resource "kubernetes_namespace" "kastenio_aks01" {
  provider   = kubernetes.aks01
  depends_on = [azurerm_kubernetes_cluster.hol-cluster01,helm_release.az-volumesnapclass01]
  metadata {
    name = "kasten-io"
  }
}

## Kasten Helm
resource "helm_release" "k10_aks01" {
  provider   = helm.aks01
  depends_on = [kubernetes_namespace.kastenio_aks01]  
  name = "k10"
  namespace = kubernetes_namespace.kastenio_aks01.metadata.0.name
  repository = "https://charts.kasten.io/"
  chart      = "k10"
  
  set {
    name  = "externalGateway.create"
    value = true
  }

  set {
    name  = "azure.useDefaultMSI"
    value = true
  } 

  set {
    name  = "auth.basicAuth.enabled"
    value = true
  } 

  set {
    name  = "auth.basicAuth.htpasswd"
    value = "admin:${htpasswd_password.hash.apr1}"
  } 
}

## Getting Kasten LB Address
data "kubernetes_service_v1" "gateway-ext_aks01" {
  provider   = kubernetes.aks01
  depends_on = [helm_release.k10_aks01]
  metadata {
    name = "gateway-ext"
    namespace = "kasten-io"
  }
}

## Accepting EULA
resource "kubernetes_config_map" "eula_aks01" {
  provider   = kubernetes.aks01
  depends_on = [helm_release.k10_aks01]
  metadata {
    name = "k10-eula-info"
    namespace = "kasten-io"
  }
  data = {
    accepted = "true"
    company  = "Veeam"
    email = var.owner_aks
  }
}


## Kasten Azure Blob Location Profile
resource "helm_release" "az-blob-locprofile01" {
  provider   = helm.aks01
  depends_on = [helm_release.k10_aks01]
  name = "${var.cluster_name01}-az-blob-locprofile"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "az-blob-locprofile"  
  
  set {
    name  = "K10Location.bucketname"
    value = azurerm_storage_account.repository01.name
  }
  set {
    name  = "K10Location.azure_storage_env"
    value = "AzureCloud"
  }
  set {
    name  = "K10Location.azure_storage_key"
    value = azurerm_storage_account.repository01.primary_access_key
  }  
}

## Kasten K10 Policy Preset
resource "helm_release" "k10-config-aks01" {
  provider   = helm.aks01
  depends_on = [helm_release.k10_aks01]
  name = "${var.cluster_name01}-k10-config"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-config"  
  
  set {
    name  = "bucketname"
    value = azurerm_storage_account.repository01.name
  }

  set {
    name  = "buckettype"
    value = "azblob"
  }
}


## Kasten K10 - TransformSet
resource "helm_release" "k10-TransformSet-aks01" {
  provider   = helm.aks01
  depends_on = [helm_release.k10_aks01]
  name = "${var.cluster_name01}-k10-transformset"
  namespace = "kasten-io"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-transformset-sc"  
  
  set {
    name  = "storageclass"
    value = "aks01-storage-class"
  }
}

