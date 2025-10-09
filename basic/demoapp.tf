## Demo k10app

resource "kubernetes_namespace" "pacman" {
  provider   = kubernetes.aks01
  depends_on = [azurerm_kubernetes_cluster.hol-cluster01,helm_release.k10_aks01]

  metadata {
    name = "pacman"
    labels = {
      environment = "demo"
    }
  }
}

resource "helm_release" "pacman" {
  provider   = helm.aks01
  depends_on = [kubernetes_namespace.pacman]

  name = "pacman"
  namespace = kubernetes_namespace.pacman.metadata[0].name
  create_namespace = false

  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "pacman" 
}

## Getting k10app LB Address
data "kubernetes_service_v1" "pacman" {
  provider   = kubernetes.aks01
  depends_on = [helm_release.pacman]
  metadata {
    name = "pacman"
    namespace = "pacman"
  }
}

