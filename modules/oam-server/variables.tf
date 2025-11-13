variable "oam_server_name" {
  description = "The name of the OAM server instance."
  type        = string
}

variable "oam_server_machine_type" {
  description = "The machine type for the OAM server instance."
  type        = string
  default     = "e2-medium"
}

variable "oam_server_zone" {
  description = "The zone where the OAM server instance will be created."
  type        = string
}

variable "oam_server_network" {
  description = "The VPC network to which the OAM server will be connected."
  type        = string
}

variable "oam_server_subnetwork" {
  description = "The subnetwork to which the OAM server will be connected."
  type        = string
}

variable "oam_server_disk_size" {
  description = "The size of the disk for the OAM server instance in GB."
  type        = number
  default     = 10
}

variable "oam_server_tags" {
  description = "A list of tags to apply to the OAM server instance."
  type        = list(string)
  default     = []
}

variable "oam_server_service_account" {
  description = "The service account to be used by the OAM server instance."
  type        = string
}