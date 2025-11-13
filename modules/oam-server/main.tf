resource "google_compute_instance" "oam_server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    "startup-script" = var.startup_script
  }

  service_account {
    email  = var.service_account_email
    scopes = var.scopes
  }

  tags = var.tags
}

output "oam_server_ip" {
  value = google_compute_instance.oam_server.network_interface[0].access_config[0].nat_ip
}