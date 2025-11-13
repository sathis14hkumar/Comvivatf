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

variable "enable_logging" {
  description = "Enable Cloud Logging."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring."
  type        = bool
  default     = true
}

variable "log_sink_name" {
  description = "The name of the log sink for exporting logs."
  type        = string
  default     = "test-log-sink"
}

variable "monitoring_alert_policy_name" {
  description = "The name of the monitoring alert policy."
  type        = string
  default     = "test-alert-policy"
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {
    environment = "test"
    team        = "devops"
  }
}