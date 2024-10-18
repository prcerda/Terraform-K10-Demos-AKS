# Define Terraform provider
terraform {
  required_version = "~> 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4"   
    }
  }
}


data "terraform_remote_state" "aks01" {
  backend = "local"

  config = {
    path = "../basic/terraform.tfstate"
  }
}

# Configure the Azure provider 01
provider "kubernetes" {
  alias = "aks01"
    host                   = data.terraform_remote_state.aks01.outputs.kube_config_pass_01.host
    client_certificate     = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_01.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_01.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_01.cluster_ca_certificate)
}

# Configure the Azure provider 02
provider "kubernetes" {
  alias = "aks02"
    host                   = data.terraform_remote_state.aks01.outputs.kube_config_pass_02.host
    client_certificate     = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_02.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_02.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aks01.outputs.kube_config_pass_02.cluster_ca_certificate)
}




