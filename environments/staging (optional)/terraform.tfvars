project_id = "your-project-id"
region = "us-central1"
zone = "us-central1-a"
vpc_name = "test-vpc"
subnet_name = "test-subnet"
cloud_sql_instance_name = "test-sql-instance"
gke_cluster_name = "test-gke-cluster"
oam_server_name = "test-oam-server"
storage_bucket_name = "test-storage-bucket"
dns_zone_name = "test-dns-zone"
load_balancer_name = "test-load-balancer"
environment = "staging"

# IAM roles
iam_roles = [
  "roles/viewer",
  "roles/compute.admin",
  "roles/container.admin",
  "roles/cloudsql.admin",
  "roles/storage.admin",
  "roles/dns.admin",
  "roles/logging.admin"
]

# Tags for resources
tags = {
  "environment" = "staging"
}