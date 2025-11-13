variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The region where resources will be created."
  type        = string
  default     = "us-central1"
}

variable "service_account_email" {
  description = "The email of the service account to assign roles."
  type        = string
}

variable "roles" {
  description = "A map of roles to assign to the service account."
  type        = map(string)
}

variable "environment" {
  description = "The environment for which the IAM roles are being set up."
  type        = string
  default     = "test"
}