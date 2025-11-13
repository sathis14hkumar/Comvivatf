variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The region where the GKE cluster will be created."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the GKE cluster."
  type        = number
  default     = 3
}

variable "node_machine_type" {
  description = "The machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}

variable "max_pods_per_node" {
  description = "The maximum number of pods per node."
  type        = number
  default     = 110
}

variable "network" {
  description = "The VPC network to which the GKE cluster will be connected."
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to which the GKE cluster will be connected."
  type        = string
}

variable "ip_range_pods" {
  description = "The IP range for the GKE cluster's pods."
  type        = string
}

variable "ip_range_services" {
  description = "The IP range for the GKE cluster's services."
  type        = string
}

variable "enable_private_nodes" {
  description = "Whether to enable private nodes for the GKE cluster."
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range for the GKE master."
  type        = string
  default     = "172.16.0.0/28"
}

variable "tags" {
  description = "A list of tags to apply to the GKE resources."
  type        = list(string)
  default     = []
}