output "logging_sink" {
  value = google_logging_project_sink.cloud_operations_sink.id
}

output "monitoring_alert_policy" {
  value = google_monitoring_alert_policy.alert_policy.id
}

output "monitoring_notification_channel" {
  value = google_monitoring_notification_channel.notification_channel.id
}

output "logging_view" {
  value = google_logging_view.logging_view.id
}