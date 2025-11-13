variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The region where resources will be created."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone where resources will be created."
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "test-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "test-subnet"
}

variable "cloud_sql_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
  default     = "test-sql-instance"
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "test-gke-cluster"
}

variable "oam_server_instance_name" {
  description = "The name of the OAM server instance."
  type        = string
  default     = "test-oam-server"
}

variable "storage_bucket_name" {
  description = "The name of the storage bucket."
  type        = string
  default     = "test-storage-bucket"
}

variable "dns_zone_name" {
  description = "The name of the DNS zone."
  type        = string
  default     = "test-dns-zone"
}

variable "load_balancer_name" {
  description = "The name of the load balancer."
  type        = string
  default     = "test-load-balancer"
}

variable "enable_logging" {
  description = "Enable logging for Cloud Operations."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring for Cloud Operations."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {
    Environment = "test"
    Project     = "gcp-terraform-test-env"
  }
}