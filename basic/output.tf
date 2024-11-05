output "demoapp_url" {
  description = "Demo App URL"
  value = "http://${kubernetes_service_v1.stock-demo-svc.status.0.load_balancer.0.ingress.0.ip}"
}

output "pacman_url" {
  description = "Pacman URL"
  value = "http://${data.kubernetes_service_v1.pacman.status.0.load_balancer.0.ingress.0.ip}"  
}

output "k10app_url" {
  description = "K10App URL"
  value = "http://${data.kubernetes_service_v1.k10app.status.0.load_balancer.0.ingress.0.ip}"  
}

output "az_bucket_name_global" {
  description = "Azure Storage Account name - Global"
  value = azurerm_storage_account.repository_global.name
}

output "aks01_cluster_name" {
  value = azurerm_kubernetes_cluster.aks-cluster01.name
}
output "aks02_cluster_name" {
  value = azurerm_kubernetes_cluster.aks-cluster02.name
}

output "kubeconfig_aks01" {
  description = "Configure kubeconfig to access this cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.demo_rgroup01.name} --name ${azurerm_kubernetes_cluster.aks-cluster01.name} --context k10-aks-primary"
}
output "kubeconfig_aks02" {
  description = "Configure kubeconfig to access this cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.demo_rgroup02.name} --name ${azurerm_kubernetes_cluster.aks-cluster02.name} --context k10-aks-secondary"
}

output "aks01_k10url" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext_aks01.status.0.load_balancer.0.ingress.0.ip}/k10/"
}

output "aks02_k10url" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext_aks02.status.0.load_balancer.0.ingress.0.ip}/k10/"
}

output "username" {
  value = "admin"
}

output "password" {
  value = var.admin_password
}

output "az_bucket_key_global" {
  value = nonsensitive(azurerm_storage_account.repository_global.primary_access_key)
}

output "kube_config_pass_01" {
  value     = azurerm_kubernetes_cluster.aks-cluster01.kube_config[0]
  sensitive = true
}

output "kube_config_pass_02" {
  value     = azurerm_kubernetes_cluster.aks-cluster02.kube_config[0]
  sensitive = true
}