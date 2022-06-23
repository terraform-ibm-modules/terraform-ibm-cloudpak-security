variable "region" {
  description = "The region name that the cluster is currently running in"
}

variable "resource_group_name" {
  description = "The resource group name that the cluster is currently running under"
}

variable "cluster_name_id" {
  description = "The name or the id of the cluster.  Cluster id is to be depreciated"
}

variable "cluster_config_path" {
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

variable "admin_user" {
  type        = string
  description = "value of ldap admin uid"
}

