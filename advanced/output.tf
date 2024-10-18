output "az_bucket_name_global" {
  description = "Azure Storage Account name - Global"
  value = data.terraform_remote_state.aks01.outputs.az_bucket_name_global
}

output "az_bucket_key_global" {
  value = nonsensitive(data.terraform_remote_state.aks01.outputs.az_bucket_key_global)
}


