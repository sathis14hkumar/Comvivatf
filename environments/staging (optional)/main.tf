resource "google_project" "staging_project" {
  name       = "Staging Environment"
  project_id = var.project_id
  org_id     = var.org_id
  billing_account = var.billing_account

  labels = {
    environment = "staging"
    team        = var.team
  }
}

module "vpc" {
  source     = "../modules/vpc"
  project_id = google_project.staging_project.project_id
  region     = var.region
  network_name = var.network_name
}

module "cloudsql" {
  source     = "../modules/cloudsql"
  project_id = google_project.staging_project.project_id
  region     = var.region
  db_instance_name = var.db_instance_name
  db_user = var.db_user
  db_password = var.db_password
}

module "gke" {
  source     = "../modules/gke"
  project_id = google_project.staging_project.project_id
  region     = var.region
  cluster_name = var.cluster_name
  node_count = var.node_count
}

module "oam_server" {
  source     = "../modules/oam-server"
  project_id = google_project.staging_project.project_id
  region     = var.region
  instance_name = var.oam_instance_name
}

module "storage" {
  source     = "../modules/storage"
  project_id = google_project.staging_project.project_id
  region     = var.region
  bucket_name = var.bucket_name
}

module "load_balancer" {
  source     = "../modules/load-balancer"
  project_id = google_project.staging_project.project_id
  region     = var.region
  lb_name = var.lb_name
}

module "dns" {
  source     = "../modules/dns"
  project_id = google_project.staging_project.project_id
  dns_zone_name = var.dns_zone_name
}

module "cloud_operations" {
  source     = "../modules/cloud-operations"
  project_id = google_project.staging_project.project_id
}

module "iam" {
  source     = "../modules/iam"
  project_id = google_project.staging_project.project_id
  roles = var.iam_roles
}

output "project_id" {
  value = google_project.staging_project.project_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "cloud_sql_instance" {
  value = module.cloudsql.db_instance_name
}

output "oam_instance" {
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