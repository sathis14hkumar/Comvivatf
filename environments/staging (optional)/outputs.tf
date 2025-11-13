output "vpc_id" {
  value = module.vpc.vpc_id
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "cloud_sql_instance_name" {
  value = module.cloudsql.instance_name
}

output "oam_server_instance_name" {
  value = module.oam_server.instance_name
}

output "storage_bucket_name" {
  value = module.storage.bucket_name
}

output "load_balancer_ip" {
  value = module.load_balancer.ip_address
}

output "dns_zone_name" {
  value = module.dns.zone_name
}

output "cloud_operations_logging" {
  value = module.cloud_operations.logging
}

output "iam_roles" {
  value = module.iam.roles
}