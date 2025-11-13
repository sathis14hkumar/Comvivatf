output "bucket_name" {
  value = google_storage_bucket.storage_bucket.name
}

output "bucket_location" {
  value = google_storage_bucket.storage_bucket.location
}

output "bucket_url" {
  value = google_storage_bucket.storage_bucket.url
}