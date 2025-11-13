resource "google_logging_project_sink" "log_sink" {
  name        = "${var.project_id}-log-sink"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.dataset_id}"
  filter      = "severity>=ERROR"

  iam_member {
    role   = "roles/logging.logWriter"
    member = "serviceAccount:${google_service_account.logging_service_account.email}"
  }
}

resource "google_service_account" "logging_service_account" {
  account_id   = "logging-service-account"
  display_name = "Logging Service Account"
  project      = var.project_id
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "High CPU Usage Alert"
  project      = var.project_id

  conditions {
    display_name = "VM Instance High CPU Usage"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      comparison = "COMPARISON_GT"
      threshold  = 80
      aggregations {
        alignment_period = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_notification_channel.id]
}

resource "google_monitoring_notification_channel" "email_notification_channel" {
  display_name = "Email Notification Channel"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
}

resource "google_monitoring_uptime_check_config" "uptime_check" {
  display_name = "Uptime Check"
  project      = var.project_id
  timeout      = "5s"
  period       = "60s"

  http_check {
    path = "/"
    port = 80
    request_method = "GET"
  }

  resource_group {
    group_id = var.uptime_check_group_id
  }
}