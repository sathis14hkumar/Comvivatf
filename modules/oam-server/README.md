# OAM Server Module

This module provisions the OAM (Open Application Model) server in Google Cloud Platform (GCP) as part of the test environment setup. It is designed to be reusable and configurable, following Terraform best practices.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "oam_server" {
  source = "../modules/oam-server"

  # Required variables
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  # Optional variables
  instance_type = var.instance_type
  machine_image = var.machine_image
}
```

## Inputs

| Name            | Description                                   | Type   | Default | Required |
|-----------------|-----------------------------------------------|--------|---------|:--------:|
| project_id      | The ID of the project in which to create resources. | string | n/a     | yes      |
| region          | The region to deploy the OAM server.         | string | n/a     | yes      |
| zone            | The zone to deploy the OAM server.           | string | n/a     | yes      |
| instance_type   | The type of VM instance to create.            | string | "n1-standard-1" | no       |
| machine_image   | The machine image to use for the instance.   | string | "debian-cloud/debian-10" | no       |

## Outputs

| Name            | Description                                   |
|-----------------|-----------------------------------------------|
| oam_server_ip   | The IP address of the OAM server instance.   |
| oam_server_name | The name of the OAM server instance.         |

## Example

```hcl
module "oam_server" {
  source = "../modules/oam-server"

  project_id      = "my-gcp-project"
  region          = "us-central1"
  zone            = "us-central1-a"
  instance_type   = "n1-standard-2"
  machine_image   = "debian-cloud/debian-10"
}
```

## Requirements

- Terraform 1.0 or later
- Google Cloud SDK configured with appropriate permissions

## Author

This module is maintained by [Your Name or Organization].