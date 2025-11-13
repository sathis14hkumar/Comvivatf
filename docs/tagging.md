# Tagging Strategy for GCP Test Environment

This document outlines the tagging strategy used in the GCP Test Environment to ensure proper resource management, cost tracking, and organization.

## Tagging Guidelines

1. **Consistency**: All resources must follow a consistent tagging format to facilitate easy identification and management.

2. **Required Tags**:
   - `Environment`: Indicates the environment (e.g., `test`, `staging`, `production`).
   - `Project`: The name of the project or application (e.g., `gcp-terraform-test-env`).
   - `Owner`: The individual or team responsible for the resource (e.g., `dev-team`).
   - `Cost Center`: The department or cost center associated with the resource (e.g., `engineering`).

3. **Optional Tags**:
   - `Purpose`: A brief description of the resource's purpose (e.g., `web-server`, `database`).
   - `Created By`: The user or automation tool that created the resource.
   - `Created Date`: The date when the resource was created.

## Implementation

Tags should be implemented in the Terraform modules as follows:

```hcl
resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  labels = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    Cost_Center = var.cost_center
  }
}
```

## Best Practices

- Regularly review and update tags to ensure they remain relevant.
- Use automation tools to enforce tagging policies across all resources.
- Monitor costs associated with each tag to identify areas for optimization.

By adhering to this tagging strategy, we can improve resource management, enhance visibility, and facilitate better cost tracking within the GCP Test Environment.