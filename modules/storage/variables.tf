variable "bucket_name" {
  description = "The name of the GCS bucket to create for shared storage."
  type        = string
}

variable "location" {
  description = "The location where the GCS bucket will be created."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "The storage class for the GCS bucket."
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Enable versioning for the GCS bucket."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels to assign to the GCS bucket."
  type        = map(string)
  default     = {}
}