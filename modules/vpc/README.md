# VPC Module

This module is responsible for creating a Virtual Private Cloud (VPC) in Google Cloud Platform (GCP). It includes the configuration for the VPC itself as well as subnets, firewall rules, and any necessary routing.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "vpc" {
  source              = "../modules/vpc"
  project_id         = var.project_id
  network_name       = var.network_name
  region             = var.region
  subnet_cidrs       = var.subnet_cidrs
  enable_private_ip  = var.enable_private_ip
  tags               = var.tags
}
```

## Inputs

| Name              | Description                                      | Type          | Default | Required |
|-------------------|--------------------------------------------------|---------------|---------|:--------:|
| project_id        | The ID of the project where the VPC will be created | string        | n/a     | yes      |
| network_name      | The name of the VPC network                      | string        | n/a     | yes      |
| region            | The region where the VPC will be created        | string        | n/a     | yes      |
| subnet_cidrs      | List of CIDR blocks for subnets                 | list(string)  | n/a     | yes      |
| enable_private_ip | Enable private IP for the VPC                   | bool          | false   | no       |
| tags              | A map of tags to assign to the VPC resources    | map(string)   | {}      | no       |

## Outputs

| Name              | Description                                      |
|-------------------|--------------------------------------------------|
| vpc_id            | The ID of the created VPC                        |
| subnet_ids        | List of IDs of the created subnets               |
| network_name      | The name of the created VPC                      |

## Example

```hcl
module "vpc" {
  source              = "../modules/vpc"
  project_id         = "my-gcp-project"
  network_name       = "test-vpc"
  region             = "us-central1"
  subnet_cidrs       = ["10.0.0.0/24", "10.0.1.0/24"]
  enable_private_ip  = true
  tags               = {
    environment = "test"
    team        = "devops"
  }
}
```

## Requirements

- Terraform 0.12 or later
- Google Cloud SDK configured with appropriate permissions

## Notes

- Ensure that the necessary IAM roles are assigned to the service account used for Terraform operations.
- Review the firewall rules created by this module to ensure they meet your security requirements.