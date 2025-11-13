variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The region where the VPC will be created."
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "test-vpc"
}

variable "subnet_cidrs" {
  description = "A list of CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "subnet_names" {
  description = "A list of names for the subnets."
  type        = list(string)
  default     = ["test-subnet"]
}

variable "enable_private_google_access" {
  description = "Enable private Google access for the subnet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the VPC and subnets."
  type        = map(string)
  default     = {
    Environment = "test"
    Project     = "gcp-terraform-test-env"
  }
}