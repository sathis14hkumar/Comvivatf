variable "dns_zone_name" {
  description = "The name of the DNS zone."
  type        = string
}

variable "dns_zone_dns_name" {
  description = "The DNS name for the zone."
  type        = string
}

variable "dns_records" {
  description = "A list of DNS records to create."
  type        = list(object({
    name    = string
    type    = string
    ttl     = number
    rdata   = list(string)
  }))
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "location" {
  description = "The location for the DNS resources."
  type        = string
  default     = "global"
}