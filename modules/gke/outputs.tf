output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "gke_cluster_location" {
  value = google_container_cluster.primary.location
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "gke_cluster_master_version" {
  value = google_container_cluster.primary.master_version
}

output "gke_cluster_node_pools" {
  value = google_container_node_pool.primary.*.name
}

output "gke_cluster_node_pool_count" {
  value = length(google_container_node_pool.primary)
}