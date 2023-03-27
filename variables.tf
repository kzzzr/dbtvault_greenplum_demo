variable "greenplum_password" {
  description = "Greenplum admin password"
  type        = string
  sensitive   = true
}
variable "folder_id" {
  description = "YC Folder ID"
  type        = string
}

output "greenplum_host_fqdn" {
  value = resource.yandex_mdb_greenplum_cluster.greenplum_cluster.master_hosts[0].fqdn
}
output "access_key" {
  value = resource.yandex_iam_service_account_static_access_key.sa-static-key.access_key
}
output "secret_key" {
  value = resource.yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}
