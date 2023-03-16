variable "greenplum_password" {
  description = "Greenplum admin password"
  type        = string
  sensitive   = true
}

output "greenplum_host_fqdn" {
  value = resource.yandex_mdb_greenplum_cluster.greenplum_cluster.master_hosts[0].fqdn
}
