output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_address.load_balancer_ip.address
}

output "load_balancer_url" {
  description = "The URL of the load balancer"
  value       = "http://${google_compute_global_address.load_balancer_ip.address}"
}

output "backend_service_id" {
  description = "The ID of the backend service"
  value       = google_compute_backend_service.default.id
}

output "url_map_id" {
  description = "The ID of the URL map"
  value       = google_compute_url_map.default.id
}