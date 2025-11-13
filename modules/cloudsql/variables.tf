variable "instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "database_version" {
  description = "The database version for the Cloud SQL instance."
  type        = string
  default     = "POSTGRES_13"
}

variable "region" {
  description = "The region where the Cloud SQL instance will be created."
  type        = string
}

variable "zone" {
  description = "The zone where the Cloud SQL instance will be created."
  type        = string
}

variable "tier" {
  description = "The machine type for the Cloud SQL instance."
  type        = string
  default     = "db-f1-micro"
}

variable "root_password" {
  description = "The root password for the Cloud SQL instance."
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "The name of the database to create in the Cloud SQL instance."
  type        = string
}

variable "authorized_networks" {
  description = "A list of authorized networks for the Cloud SQL instance."
  type        = list(string)
  default     = []
}

variable "backup_enabled" {
  description = "Enable backups for the Cloud SQL instance."
  type        = bool
  default     = true
}

variable "backup_window_start" {
  description = "The start time for the backup window."
  type        = string
  default     = "03:00"
}

variable "backup_window_end" {
  description = "The end time for the backup window."
  type        = string
  default     = "04:00"
}

variable "tags" {
  description = "A map of tags to assign to the Cloud SQL instance."
  type        = map(string)
  default     = {}
}