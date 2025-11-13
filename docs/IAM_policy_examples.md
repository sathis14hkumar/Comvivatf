# IAM Policy Examples for GCP Terraform Setup

This document provides examples of IAM policies that can be used in the GCP Terraform setup for the Test Environment. These policies are designed to follow the principle of least privilege, ensuring that users and services have only the permissions they need to perform their tasks.

## Example IAM Policies

### 1. Compute Engine Instance Admin

This role allows users to create and manage Compute Engine instances.

```hcl
resource "google_project_iam_member" "compute_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin"
  member  = "user:${var.user_email}"
}
```

### 2. Cloud SQL Admin

This role allows users to manage Cloud SQL instances.

```hcl
resource "google_project_iam_member" "cloud_sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "user:${var.user_email}"
}
```

### 3. Kubernetes Engine Admin

This role allows users to manage Kubernetes clusters and resources.

```hcl
resource "google_project_iam_member" "kubernetes_engine_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "user:${var.user_email}"
}
```

### 4. Storage Admin

This role allows users to manage GCS buckets and objects.

```hcl
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "user:${var.user_email}"
}
```

### 5. Viewer Role

This role grants read-only access to all resources in the project.

```hcl
resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:${var.user_email}"
}
```

## Custom Roles

For more granular control, consider creating custom roles tailored to specific needs. Below is an example of how to create a custom role.

```hcl
resource "google_project_iam_custom_role" "custom_role" {
  role_id     = "customRoleId"
  title       = "Custom Role Title"
  description = "Description of the custom role"
  permissions = [
    "compute.instances.start",
    "compute.instances.stop",
  ]
  project = var.project_id
}
```

## Conclusion

These examples can be adapted to fit the specific needs of your project. Always review and test IAM policies to ensure they provide the necessary access without over-permissioning.