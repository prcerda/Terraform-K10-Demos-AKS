## Demo k10app

resource "kubernetes_namespace" "k10app" {
  provider   = kubernetes.aks01
  depends_on = [azurerm_kubernetes_cluster.hol-cluster01,helm_release.k10_aks01]

  metadata {
    name = "k10app"
    labels = {
      environment = "demo"
    }
  }
}

resource "helm_release" "k10app" {
  provider   = helm.aks01
  depends_on = [kubernetes_namespace.k10app]

  name = "k10app"
  namespace = kubernetes_namespace.k10app.metadata[0].name
  create_namespace = false

  repository = "https://k10app.github.io/k10app/"
  chart      = "k10app"
  
  set {
    name  = "serviceType"
    value = "LoadBalancer"
  }
}

## Getting k10app LB Address
data "kubernetes_service_v1" "k10app" {
  provider   = kubernetes.aks01
  depends_on = [helm_release.k10app]
  metadata {
    name = "router"
    namespace = "k10app"
  }
}

## Demo Pacman

resource "kubernetes_namespace" "pacman" {
  provider   = kubernetes.aks02
  depends_on = [azurerm_kubernetes_cluster.hol-cluster02,helm_release.k10_aks02]

  metadata {
    name = "pacman"
    labels = {
      environment = "demo"
    }
  }
}

resource "helm_release" "pacman" {
  provider   = helm.aks02
  depends_on = [kubernetes_namespace.pacman]

  name = "pacman"
  namespace = kubernetes_namespace.pacman.metadata[0].name
  create_namespace = false

  repository = "https://shuguet.github.io/pacman/"
  chart      = "pacman"
  
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

## Getting k10app LB Address
data "kubernetes_service_v1" "pacman" {
  provider   = kubernetes.aks02
  depends_on = [helm_release.pacman]
  metadata {
    name = "pacman"
    namespace = "pacman"
  }
}

