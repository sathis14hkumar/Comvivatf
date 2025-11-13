# Storage Module Documentation

This directory contains the Terraform configuration for managing storage resources in Google Cloud Platform (GCP). The storage module can be used to create and manage Google Cloud Storage (GCS) buckets or Filestore instances, depending on your requirements.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "storage" {
  source     = "../modules/storage"
  bucket_name = var.bucket_name
  location    = var.location
  ...
}
```

## Inputs

| Name         | Description                          | Type   | Default | Required |
|--------------|--------------------------------------|--------|---------|:--------:|
| bucket_name  | The name of the GCS bucket.         | string | n/a     | yes      |
| location     | The location for the GCS bucket.    | string | "US"    | no       |
| ...          | Additional variables as needed.      |        |         |          |

## Outputs

| Name          | Description                          |
|---------------|--------------------------------------|
| bucket_url    | The URL of the created GCS bucket.  |
| ...           | Additional outputs as needed.        |

## Examples

For examples of how to use this module, please refer to the `examples` directory.

## Best Practices

- Ensure that the bucket name is globally unique.
- Use appropriate IAM roles to manage access to the storage resources.
- Consider enabling versioning and lifecycle management for your buckets.

## License

This module is licensed under the MIT License. See the LICENSE file for more information.