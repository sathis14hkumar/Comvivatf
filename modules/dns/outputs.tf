output "dns_zone_name" {
  value = google_dns_managed_zone.dns_zone.name
}

output "dns_zone_dns_name" {
  value = google_dns_managed_zone.dns_zone.dns_name
}

output "dns_records" {
  value = google_dns_record_set.dns_records.*.name
}