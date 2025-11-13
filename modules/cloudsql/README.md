# Cloud SQL Module

This module provisions a Cloud SQL instance in Google Cloud Platform (GCP). It is designed to be reusable and configurable for different environments.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "cloudsql" {
  source          = "../modules/cloudsql"
  instance_name   = var.instance_name
  database_version = var.database_version
  region          = var.region
  tier            = var.tier
  root_password   = var.root_password
  project_id      = var.project_id
}
```

## Inputs

| Name              | Description                                   | Type   | Default | Required |
|-------------------|-----------------------------------------------|--------|---------|:--------:|
| instance_name     | The name of the Cloud SQL instance            | string | n/a     |   yes    |
| database_version   | The database version (e.g., "POSTGRES_12")   | string | n/a     |   yes    |
| region            | The region where the instance will be created | string | n/a     |   yes    |
| tier              | The machine type for the instance             | string | "db-f1-micro" | no |
| root_password     | The password for the root user                | string | n/a     |   yes    |
| project_id        | The GCP project ID                            | string | n/a     |   yes    |

## Outputs

| Name              | Description                                   |
|-------------------|-----------------------------------------------|
| instance_connection_name | The connection name of the Cloud SQL instance |
| instance_ip       | The IP address of the Cloud SQL instance      |
| instance_name     | The name of the Cloud SQL instance            |

## Requirements

- Terraform 0.12 or later
- Google Cloud SDK

## Example

```hcl
module "cloudsql" {
  source          = "../modules/cloudsql"
  instance_name   = "test-sql-instance"
  database_version = "POSTGRES_12"
  region          = "us-central1"
  tier            = "db-f1-micro"
  root_password   = "your-secure-password"
  project_id      = "your-gcp-project-id"
}
```

## Notes

- Ensure that the necessary IAM permissions are granted to the service account used by Terraform to create Cloud SQL instances.
- Follow best practices for managing sensitive information, such as using Terraform Vault or Secrets Manager for passwords.