resource "google_storage_bucket" "test_bucket" {
  name     = var.bucket_name
  location = var.location

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "bucket_member" {
  for_each = var.iam_members

  bucket = google_storage_bucket.test_bucket.name
  role   = each.value.role
  member = each.value.member
}