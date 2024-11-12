## Demo Stock app

resource "kubernetes_namespace" "stock" {
  provider   = kubernetes.aks02
  depends_on = [azurerm_kubernetes_cluster.hol-cluster02,helm_release.az-volumesnapclass02]

  metadata {
    name = "stock"
    labels = {
      environment = "demo"
    }
  }
}

resource "helm_release" "stockgres" {
  provider   = helm.aks02
  depends_on = [kubernetes_namespace.stock]

  name = "stockdb"
  namespace = kubernetes_namespace.stock.metadata[0].name
  create_namespace = false

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  
  set {
    name  = "global.postgresql.auth.username"
    value = "root"
  }

  set {
    name  = "global.postgresql.auth.password"
    value = "notsecure"
  }

  set {
    name  = "global.postgresql.auth.database"
    value = "stock"
  }
}

resource "kubernetes_config_map" "stockcm" {
  provider   = kubernetes.aks02
  depends_on = [kubernetes_namespace.stock]

  metadata {
    name = "stock-demo-configmap"
    namespace = kubernetes_namespace.stock.metadata[0].name
  }

  data = {
    "initinsert.psql" = "${file("${path.module}/initinsert.psql")}"
  }
}

resource "kubernetes_deployment" "stock-deploy" {
  provider   = kubernetes.aks02
  depends_on = [kubernetes_namespace.stock]

  metadata {
    name = "stock-demo-deploy"
    namespace = kubernetes_namespace.stock.metadata[0].name
    labels = {
      app = "stock-demo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "stock-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "stock-demo"
        }
      }

      spec {
        volume {
          name = "config"
          config_map {
            name = "stock-demo-configmap"
          }
        }
        container {
          image = "tdewin/stock-demo"
          name  = "stock-demo"
          port {
            name = "stock-demo"
            container_port = "8080"
            protocol = "TCP"
          }
          volume_mount {
            name = "config"
            mount_path = "/var/stockdb"
            read_only = true
          }
          env {
              name = "POSTGRES_DB"
              value = "stock"
          }

          env {
              name = "POSTGRES_SERVER"
              value = "stockdb-postgresql"
          }

          env {
              name = "POSTGRES_USER"
              value = "root"
          }
          env {
              name = "POSTGRES_PORT"
              value = "5432"
          }
          env {
              name = "ADMINKEY"
              value = "unlock"
          }
          env {
              name = "POSTGRES_PASSWORD"
              value_from {
                secret_key_ref {
                  key = "password"
                  name = "stockdb-postgresql"
                }
              }
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "stock-demo-svc" {
  provider   = kubernetes.aks02
  depends_on = [kubernetes_namespace.stock]

  metadata {
    name = "stock-demo-svc"
    namespace = kubernetes_namespace.stock.metadata[0].name
    labels = {
      app = "stock-demo"
    }
  }
  spec {
    selector = {
      app = "stock-demo"
    }
    
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}


## Demo k10app

resource "kubernetes_namespace" "k10app" {
  provider   = kubernetes.aks01
  depends_on = [azurerm_kubernetes_cluster.hol-cluster01,helm_release.az-volumesnapclass01]

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
  depends_on = [azurerm_kubernetes_cluster.hol-cluster02,helm_release.az-volumesnapclass02]

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

