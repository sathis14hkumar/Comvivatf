output "cloud_sql_instance_name" {
  value = google_sql_database_instance.instance.name
}

output "cloud_sql_instance_connection_name" {
  value = google_sql_database_instance.instance.connection_name
}

output "cloud_sql_instance_ip_address" {
  value = google_sql_database_instance.instance.ip_address[0].ip_address
}

output "cloud_sql_database_name" {
  value = google_sql_database.instance.database[0].name
}