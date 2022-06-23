
variable "provision_cp4s" {
  default     = true
  description = "If set to true installs Cloud-Pak for security on the given cluster"
}

variable "cluster_config_path" {
  default     = "./.kube/config/"
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

// This value is currently not being leveraged properly in insatll_cp4s
variable "namespace" {
  default     = "cp4s"
  description = "Namespace for Cloud Pak for Security"
}

variable "entitled_registry_key" {
  description = "ibm cloud pak entitlement key"
}

variable "admin_user" {
  default     = "default_user"
  description = "user to be given administartor privileges in the default account"
}
