resource "google_sql_database_instance" "default" {
  name             = var.instance_name
  database_version = var.database_version
  region          = var.region

  settings {
    tier = var.tier

    ip_configuration {
      authorized_networks = var.authorized_networks
      ipv4_enabled       = true
    }

    backup_configuration {
      enabled = var.backup_enabled
      start_time = var.backup_start_time
    }

    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour
      update_track = var.update_track
    }
  }
}

resource "google_sql_database" "default" {
  name     = var.database_name
  instance = google_sql_database_instance.default.name
  charset  = var.charset
  collation = var.collation
}

resource "google_sql_user" "default" {
  name     = var.user_name
  instance = google_sql_database_instance.default.name
  password = var.user_password
}

output "instance_connection_name" {
  value = google_sql_database_instance.default.connection_name
}

output "database_name" {
  value = google_sql_database.default.name
}

output "user_name" {
  value = google_sql_user.default.name
}