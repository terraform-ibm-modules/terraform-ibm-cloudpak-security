output "cp4s_endpoints" {
  depends_on = [
    data.external.get_cp4s_endpoints,
  ]
  value = length(data.external.get_cp4s_endpoints) > 0 ? data.external.get_cp4s_endpoints.result.endpoint : ""
}