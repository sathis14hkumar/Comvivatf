project = "gcp-terraform-test-env"
environment = "test"
region = "us-central1"
zone = "${var.region}-a"
vpc_name = "${project}-${environment}-vpc"
subnet_name = "${vpc_name}-subnet"
cloud_sql_instance_name = "${project}-${environment}-sql"
gke_cluster_name = "${project}-${environment}-gke"
oam_server_name = "${project}-${environment}-oam-server"
storage_bucket_name = "${project}-${environment}-storage"
load_balancer_name = "${project}-${environment}-lb"
dns_zone_name = "${project}-${environment}-dns"
dns_record_name = "${project}.${environment}.example.com"
service_account_name = "${project}-${environment}-sa"

# Cloud SQL configuration
cloud_sql_database = "test_db"
cloud_sql_user = "test_user"
cloud_sql_password = "test_password"

# GKE configuration
gke_node_count = 3
gke_node_machine_type = "e2-medium"

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

# Tagging
tags = {
  "environment" = "test"
  "project" = project
}