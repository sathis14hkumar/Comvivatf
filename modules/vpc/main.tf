resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false

  tags = var.tags
}

resource "google_compute_subnetwork" "subnetwork" {
  count            = length(var.subnetworks)
  name             = element(var.subnetworks, count.index)
  ip_cidr_range    = element(var.subnet_cidr_ranges, count.index)
  region           = var.region
  network          = google_compute_network.vpc_network.name
  private_ip_google_access = true

  tags = var.tags
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  tags = var.tags
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  tags = var.tags
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]

  tags = var.tags
}