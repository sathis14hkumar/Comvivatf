# Load Balancer Module

This module sets up a global load balancer in Google Cloud Platform (GCP) to distribute traffic across multiple backend services. It is designed to work seamlessly with other modules in the project, such as GKE and Cloud SQL.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "load_balancer" {
  source              = "../modules/load-balancer"
  name                = var.name
  region              = var.region
  backend_service     = var.backend_service
  health_check       = var.health_check
  frontend_ip         = var.frontend_ip
  # Add other variables as needed
}
```

## Inputs

| Name              | Description                                     | Type   | Default | Required |
|-------------------|-------------------------------------------------|--------|---------|:--------:|
| name              | The name of the load balancer                   | string | n/a     | yes      |
| region            | The region where the load balancer will be created | string | n/a     | yes      |
| backend_service    | The backend service configuration                | list   | n/a     | yes      |
| health_check      | The health check configuration                   | object | n/a     | yes      |
| frontend_ip       | The frontend IP configuration                    | object | n/a     | yes      |

## Outputs

| Name              | Description                                     |
|-------------------|-------------------------------------------------|
| load_balancer_ip  | The IP address of the load balancer             |
| backend_service_id| The ID of the created backend service            |

## Example

```hcl
module "load_balancer" {
  source              = "../modules/load-balancer"
  name                = "my-load-balancer"
  region              = "us-central1"
  backend_service     = [
    {
      name = "my-backend-service"
      # Additional backend service configuration
    }
  ]
  health_check       = {
    name = "my-health-check"
    # Additional health check configuration
  }
  frontend_ip        = {
    name = "my-frontend-ip"
    # Additional frontend IP configuration
  }
}
```

## Requirements

- Terraform 1.0 or later
- Google Cloud SDK configured with appropriate permissions

## Author

This module is maintained by [Your Name or Organization].

## License

This module is licensed under the MIT License. See the LICENSE file for more information.