## Kasten namespace K10 - MultiCluster
resource "kubernetes_namespace" "kastenio-mc" {
  provider   = kubernetes.aks01
  metadata {
    name = "kasten-io-mc"
  }
}

## Kasten K10 - MultiCluster Bootstrap
resource "kubernetes_manifest" "bootstrap_kasten_io_mc" {
  provider   = kubernetes.aks01
  depends_on = [kubernetes_namespace.kastenio-mc]
  manifest = {
    "apiVersion" = "dist.kio.kasten.io/v1alpha1"
    "kind" = "Bootstrap"
    "metadata" = {
      "name" = "bootstrap-primary"
      "namespace" = "kasten-io-mc"
    }
    "spec" = {
      "clusters" = {
        "primary-cluster" = {
          "k10" = {
            "ingress" = {
              "url" = "${data.terraform_remote_state.aks01.outputs.aks01_k10url}"
            }
            "namespace" = "kasten-io"
            "releaseName" = "k10"
          }
          "name" = "k10-hol-primary"
          "primary" = true
        }
      }
    }
  }
}

## Kasten K10 - Multicluster Create Join Token - Primary
resource "kubernetes_secret" "join_token_secret" {
  provider   = kubernetes.aks01
  depends_on = [kubernetes_manifest.bootstrap_kasten_io_mc]   
  metadata {
    generate_name = "join-token-secret-"
    namespace = "kasten-io-mc"
  }
  type = "dist.kio.kasten.io/join-token"

  # Kasten fills the "token" key after the secret is created; ignore it
  # so Terraform doesn't try to remove it on the next apply.
  lifecycle {
    ignore_changes = [data]
  }
}

## Give the Kasten controller time to populate the token
resource "time_sleep" "wait_join_token" {
  depends_on      = [kubernetes_secret.join_token_secret]
  create_duration = "30s"
}

## Read the secret back once the token has been generated
data "kubernetes_secret" "join_token_secret" {
  provider   = kubernetes.aks01
  depends_on = [time_sleep.wait_join_token]
  metadata {
    name      = kubernetes_secret.join_token_secret.metadata[0].name
    namespace = "kasten-io-mc"
  }
}


## Kasten K10 - Multicluster Use Join Token - Secondary
resource "kubernetes_secret" "join_token_aks" {
  provider   = kubernetes.aks02
  metadata {
    name = "mc-join"
    namespace = "kasten-io"
  }
  data = {
    token = data.kubernetes_secret.join_token_secret.data["token"]
  }  
}

## Kasten K10 - Multicluster Join Secondary Cluster
resource "kubernetes_config_map" "kasten-mc-secondary" {
  provider   = kubernetes.aks02
  metadata {
    name = "mc-join-config"
    namespace = "kasten-io"
  }
  data = {
    cluster-name    = "k10-hol-secondary"
    cluster-ingress = "${data.terraform_remote_state.aks01.outputs.aks02_k10url}"
    primary-ingress = "${data.terraform_remote_state.aks01.outputs.aks01_k10url}"
    allow-insecure-primary-ingress = true
  }
}

## Kasten K10 - Multi-Cluster Admin Role
resource "kubernetes_manifest" "k10clusterrolebinding_mc" {
  provider   = kubernetes.aks01
  manifest = {
    "apiVersion" = "auth.kio.kasten.io/v1alpha1"
    "kind" = "K10ClusterRoleBinding"
    "metadata" = {
      "name" = "admin-all-clusters"
      "namespace" = "kasten-io-mc"
    }
    "spec" = {
      "clusters" = [
        {
          "selector" = ""
        },
      ]
      "k10ClusterRole" = "k10-multi-cluster-admin"
      "subjects" = [
        {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "User"
          "name" = "system:serviceaccount:kasten-io:dashboardbff-svc"
        },        
        {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "User"
          "name" = "system:serviceaccount:kasten-io:k10-k10"
        },
        {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "User"
          "name" = "system:serviceaccount:kasten-io:auth-svc"
        },        
      ]
    }
  }
}