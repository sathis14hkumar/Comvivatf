resource "google_project" "test_project" {
  name       = "Test Environment Project"
  project_id = var.project_id
  org_id     = var.org_id
  billing_account = var.billing_account

  labels = {
    environment = "test"
    team        = var.team
  }
}

module "vpc" {
  source     = "../../modules/vpc"
  project_id = google_project.test_project.project_id
  region     = var.region
  cidr       = var.vpc_cidr
}

module "cloudsql" {
  source     = "../../modules/cloudsql"
  project_id = google_project.test_project.project_id
  region     = var.region
  db_name    = var.db_name
  db_user    = var.db_user
  db_password = var.db_password
}

module "gke" {
  source     = "../../modules/gke"
  project_id = google_project.test_project.project_id
  region     = var.region
  cluster_name = var.cluster_name
  node_count = var.node_count
}

module "oam_server" {
  source     = "../../modules/oam-server"
  project_id = google_project.test_project.project_id
  region     = var.region
  instance_name = var.oam_instance_name
}

module "storage" {
  source     = "../../modules/storage"
  project_id = google_project.test_project.project_id
  region     = var.region
  bucket_name = var.bucket_name
}

module "load_balancer" {
  source     = "../../modules/load-balancer"
  project_id = google_project.test_project.project_id
  region     = var.region
  backend_service_name = var.backend_service_name
}

module "dns" {
  source     = "../../modules/dns"
  project_id = google_project.test_project.project_id
  dns_zone_name = var.dns_zone_name
}

module "cloud_operations" {
  source     = "../../modules/cloud-operations"
  project_id = google_project.test_project.project_id
}

output "project_id" {
  value = google_project.test_project.project_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cloudsql_instance" {
  value = module.cloudsql.instance_name
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "oam_server_instance" {
  value = module.oam_server.instance_name
}

output "storage_bucket" {
  value = module.storage.bucket_name
}

output "load_balancer_ip" {
  value = module.load_balancer.ip_address
}

output "dns_zone" {
  value = module.dns.dns_zone_name
}