# Cloud Operations Module

This module is responsible for setting up Google Cloud Operations (formerly Stackdriver) for monitoring and logging in your GCP environment.

## Overview

The Cloud Operations module provides the necessary resources to enable logging and monitoring for your GCP services. It helps in tracking the performance and health of your applications and infrastructure.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "cloud_operations" {
  source = "../modules/cloud-operations"

  # Add your variables here
}
```

## Inputs

| Name                | Description                                   | Type   | Default | Required |
|---------------------|-----------------------------------------------|--------|---------|:--------:|
| project_id          | The ID of the GCP project.                    | string | n/a     |   yes    |
| location            | The location for the resources.               | string | n/a     |   yes    |
| logging_enabled     | Enable logging for the project.               | bool   | true    |    no    |
| monitoring_enabled   | Enable monitoring for the project.            | bool   | true    |    no    |

## Outputs

| Name                | Description                                   |
|---------------------|-----------------------------------------------|
| logging_sink        | The logging sink created for the project.    |
| monitoring_alert    | The monitoring alert policy created.          |

## Examples

For examples of how to use this module, please refer to the `examples` directory.

## Requirements

- Terraform 1.0 or later
- Google Cloud SDK

## Author

This module is maintained by [Your Name or Organization].

## License

This module is licensed under the MIT License. See the LICENSE file for more information.