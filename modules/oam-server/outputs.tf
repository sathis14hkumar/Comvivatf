output "oam_server_instance_name" {
  value = google_compute_instance.oam_server.name
}

output "oam_server_instance_ip" {
  value = google_compute_instance.oam_server.network_interface[0].access_config[0].nat_ip
}

output "oam_server_instance_zone" {
  value = google_compute_instance.oam_server.zone
}