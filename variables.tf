/********************************************************************

This file is used to declare ROOT varaibles.

E.g:

variable "at_service_name" {
  type        = string
  description = "Activity Tracker: The name of the activity tracker"
}

variable "at_bind_key" {
  description = "Activity Tracker: Enable this to bind key to instance (true/false)"
  type        = bool
  default     = false
}

variable "at_create_instance" {
  description = "Activity Tracker: Controls if Activity Tracker should be created"
  type        = bool
  default     = true
}

********************************************************************/


variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for security on the given cluster"
}

variable "cluster_config_path" {
  default = "./.kube/config/"
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

// This value is currently not being leveraged properly in insatll_cp4s
variable "namespace" {
  default = "cp4s"
  description = "Namespace for Cloud Pak for Security"
}

variable "entitled_registry_key" {
  description = "ibm cloud pak entitlement key"
}

variable "admin_user" {
  default     = "default_user"
  description = "user to be given administartor privileges in the default account"
}

locals {
  namespace              = "cp4s"
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  docker_registry        = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username        = "cp"        // "ekey"
  entitled_registry_key  = chomp(var.entitled_registry_key)
}
