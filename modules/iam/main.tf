resource "google_project_iam_member" "project_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:${var.viewer_email}"
}

resource "google_project_iam_member" "project_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "user:${var.editor_email}"
}

resource "google_project_iam_member" "cloud_sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "user:${var.sql_admin_email}"
}

resource "google_project_iam_member" "gke_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "user:${var.gke_admin_email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "user:${var.storage_admin_email}"
}

resource "google_project_iam_member" "dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "user:${var.dns_admin_email}"
}

resource "google_project_iam_member" "operations_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "user:${var.operations_admin_email}"
}