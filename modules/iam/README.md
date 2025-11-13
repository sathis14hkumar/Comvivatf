# IAM Module Documentation

This directory contains the IAM module for managing Identity and Access Management (IAM) roles and permissions in Google Cloud Platform (GCP) for the test environment.

## Overview

The IAM module is designed to set up role bindings and permissions following the principle of least privilege. This ensures that resources are secured and only accessible to the necessary users and services.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "iam" {
  source = "../modules/iam"

  # Input variables
  project_id = var.project_id
  roles      = var.roles
  members    = var.members
}
```

## Inputs

| Name        | Description                                  | Type   | Default | Required |
|-------------|----------------------------------------------|--------|---------|:--------:|
| project_id  | The ID of the GCP project                    | string | n/a     | yes      |
| roles       | A list of roles to assign                    | list   | n/a     | yes      |
| members     | A list of members to whom roles will be assigned | list   | n/a     | yes      |

## Outputs

| Name        | Description                                  |
|-------------|----------------------------------------------|
| iam_roles   | The IAM roles that were created              |

## Example

Here is an example of how to define the IAM module in your environment configuration:

```hcl
module "iam" {
  source = "../modules/iam"

  project_id = "my-gcp-project"
  roles      = ["roles/viewer", "roles/editor"]
  members    = ["user:example@example.com", "serviceAccount:my-service-account@my-gcp-project.iam.gserviceaccount.com"]
}
```

## Best Practices

- Always follow the principle of least privilege when assigning roles.
- Regularly review IAM policies and permissions to ensure they are up to date.
- Use service accounts for applications and workloads instead of user accounts.

## License

This module is licensed under the MIT License. See the LICENSE file for more information.