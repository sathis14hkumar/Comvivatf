# DNS Module Documentation

This module is responsible for managing DNS resources in Google Cloud Platform (GCP). It allows you to create and manage DNS zones and records, facilitating the configuration of domain names for your applications.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "dns" {
  source     = "../modules/dns"
  project_id = var.project_id
  dns_zone   = var.dns_zone
  dns_records = var.dns_records
}
```

## Inputs

| Name         | Description                                   | Type   | Default | Required |
|--------------|-----------------------------------------------|--------|---------|:--------:|
| project_id   | The ID of the GCP project where resources will be created. | string | n/a     | yes      |
| dns_zone     | The name of the DNS zone to create.          | string | n/a     | yes      |
| dns_records  | A list of DNS records to create.             | list   | n/a     | yes      |

## Outputs

| Name         | Description                                   |
|--------------|-----------------------------------------------|
| dns_zone_id  | The ID of the created DNS zone.              |
| dns_records  | A list of created DNS records.               |

## Example

Here is an example of how to define the inputs for this module:

```hcl
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "dns_zone" {
  description = "The DNS zone name"
  type        = string
}

variable "dns_records" {
  description = "List of DNS records"
  type        = list(object({
    name    = string
    type    = string
    ttl     = number
    rdata   = list(string)
  }))
}
```

## Requirements

- Terraform 1.0 or later
- Google Cloud SDK

## Author

This module is maintained by [Your Name or Organization].

## License

This module is licensed under the MIT License. See the LICENSE file for more information.