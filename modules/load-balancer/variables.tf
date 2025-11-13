variable "name" {
  description = "The name of the load balancer."
  type        = string
}

variable "region" {
  description = "The region where the load balancer will be created."
  type        = string
}

variable "backend_service_name" {
  description = "The name of the backend service for the load balancer."
  type        = string
}

variable "health_check_name" {
  description = "The name of the health check for the backend service."
  type        = string
}

variable "frontend_ip" {
  description = "The IP address for the frontend of the load balancer."
  type        = string
}

variable "frontend_port" {
  description = "The port for the frontend of the load balancer."
  type        = number
}

variable "backend_port" {
  description = "The port for the backend service."
  type        = number
}

variable "target_pool_name" {
  description = "The name of the target pool for the load balancer."
  type        = string
}

variable "tags" {
  description = "A list of tags to apply to the load balancer resources."
  type        = list(string)
  default     = []
}