resource "google_dns_managed_zone" "test_zone" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  visibility  = "public"

  labels = var.labels
}

resource "google_dns_record_set" "test_a_record" {
  managed_zone = google_dns_managed_zone.test_zone.name
  name         = var.a_record_name
  type         = "A"
  ttl          = var.ttl
  rrdatas      = var.a_record_ip
}

resource "google_dns_record_set" "test_cname_record" {
  managed_zone = google_dns_managed_zone.test_zone.name
  name         = var.cname_record_name
  type         = "CNAME"
  ttl          = var.ttl
  rrdatas      = var.cname_record_target
}