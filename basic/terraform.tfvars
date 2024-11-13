# AZ1 Settings
# CIDR block for the subnet inside the VNET where the appliance will be deployed.
region01    = "francecentral"
cluster_name01 = "k10mc1"

# Azure Settings
# Specify the appliance instance type.
# For the list of supported instance types, review the veeam_aws_instance_type variable in the variables.tf file.
# Default is Standard_B2s.
region02            = "westeurope"
cluster_name02      = "k10mc2"

aks_instance_type = "Standard_D2ds_v4"
aks_num_nodes = 3

# CIDR block for the new VNET where the appliance will be deployed.
aks_vnet_cidr_ipv4 = "10.50.0.0/16"

# CIDR block for the subnet inside the VNET where the appliance will be deployed.
aks_subnet_cidr_ipv4 = "10.50.1.0/24"

#Labels
owner_aks = "owner@veeam.com"
activity = "demo"
admin_password = "Veeam123!"
