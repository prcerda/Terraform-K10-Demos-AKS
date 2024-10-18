variable "region01" {
  type = string
}

variable "region02" {
  type = string
} 

variable "owner_aks" {
  type = string
}

variable "activity" {
  type = string
}

variable "admin_password" {
  type = string
}


variable "aks_subnet_cidr_ipv4" {
    type = string
}

variable "aks_vnet_cidr_ipv4" {
    type = string
}


variable "aks_num_nodes" {
  description = "number of gke nodes"
}

variable "cluster_name01" {
  type = string
}

variable "cluster_name02" {
  type = string
}


variable "aks_instance_type" {
  type = string
}

variable "tokenexpirehours" {
  type = number
  default = 36
}