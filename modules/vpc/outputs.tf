output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_ids" {
  value = google_compute_subnetwork.subnet.*.id
}

output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_self_links" {
  value = google_compute_subnetwork.subnet.*.self_link
}