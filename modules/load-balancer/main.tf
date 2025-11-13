resource "google_compute_global_address" "default" {
  name = "${var.name}-ip"
  ip_version = "IPV4"
}

resource "google_compute_backend_service" "default" {
  name        = "${var.name}-backend"
  load_balancing_scheme = "EXTERNAL"
  health_checks = [google_compute_health_check.default.id]
  backend {
    group = var.instance_group_url
  }
}

resource "google_compute_health_check" "default" {
  name = "${var.name}-health-check"
  check_interval_sec = 10
  timeout_sec = 5
  healthy_threshold = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
    request_path = "/"
  }
}

resource "google_compute_url_map" "default" {
  name = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name = "${var.name}-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "${var.name}-forwarding-rule"
  target = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.default.address
}

output "ip_address" {
  value = google_compute_global_address.default.address
}