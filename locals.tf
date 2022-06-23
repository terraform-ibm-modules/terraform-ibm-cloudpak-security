locals {
  namespace              = "cp4s"
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  docker_registry        = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username        = "cp"        // "ekey"
  entitled_registry_key  = chomp(var.entitled_registry_key)
}
