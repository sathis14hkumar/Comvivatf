# GCP Terraform Test Environment

This project provides a complete Terraform setup for a Test Environment in Google Cloud Platform (GCP). It includes the following resources:

- Virtual Private Cloud (VPC)
- Cloud SQL
- Google Kubernetes Engine (GKE)
- OAM Server
- Shared Storage
- Load Balancer
- Cloud DNS
- Cloud Operations

## Project Structure

The project is organized into modules for better reusability and maintainability. Below is the directory structure:

```
gcp-terraform-test-env
├── README.md
├── LICENSE
├── .gitignore
├── versions.tf
├── backend.tf
├── providers.tf
├── terraform.tfvars.example
├── modules
│   ├── vpc
│   ├── gke
│   ├── cloudsql
│   ├── oam-server
│   ├── storage
│   ├── load-balancer
│   ├── dns
│   ├── cloud-operations
│   └── iam
├── environments
│   ├── test
│   └── staging (optional)
├── examples
│   └── quickstart
├── scripts
├── ci
└── docs
```

## Getting Started

### Prerequisites

- Terraform installed on your local machine.
- Google Cloud SDK installed and configured.
- A GCP project with billing enabled.

### Initialization

To initialize the Terraform configuration, navigate to the `environments/test` directory and run:

```bash
cd environments/test
terraform init
```

### Planning

To see what changes will be made, run:

```bash
terraform plan
```

### Applying

To apply the changes and create the resources, run:

```bash
terraform apply
```

### Inputs and Outputs

Each module has its own set of input variables and outputs. You can find the details in the respective `variables.tf` and `outputs.tf` files within each module.

### Remote Backend

The project is configured to use a remote backend for storing the Terraform state in a Google Cloud Storage (GCS) bucket. Ensure that the bucket is created and accessible.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Documentation

For more detailed documentation on IAM policies, tagging strategies, and remote backend configuration, please refer to the `docs` directory.