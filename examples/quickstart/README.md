# Quickstart Guide for GCP Terraform Test Environment

This quickstart guide provides an overview of how to set up and deploy a test environment in Google Cloud Platform (GCP) using Terraform. The setup includes a Virtual Private Cloud (VPC), Google Kubernetes Engine (GKE), Cloud SQL, an OAM server, shared storage, a load balancer, Cloud DNS, and Cloud Operations.

## Prerequisites

- Ensure you have the following installed:
  - [Terraform](https://www.terraform.io/downloads.html)
  - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- A Google Cloud account with billing enabled.
- Permissions to create resources in GCP.

## Getting Started

1. **Clone the Repository**

   ```bash
   git clone <repository-url>
   cd gcp-terraform-test-env
   ```

2. **Set Up Google Cloud Credentials**

   Authenticate your Google Cloud account:

   ```bash
   gcloud auth login
   gcloud config set project <your-project-id>
   ```

3. **Initialize Terraform**

   Initialize the Terraform configuration:

   ```bash
   terraform init
   ```

4. **Configure Variables**

   Copy the example variables file and edit it to suit your environment:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Update `terraform.tfvars` with your specific values.

5. **Plan the Deployment**

   Run the Terraform plan to see what resources will be created:

   ```bash
   terraform plan
   ```

6. **Apply the Configuration**

   Deploy the resources defined in the Terraform configuration:

   ```bash
   terraform apply
   ```

   Confirm the action when prompted.

## Outputs

After the deployment is complete, Terraform will output important information such as:

- VPC network details
- GKE cluster endpoint
- Cloud SQL instance connection details
- Load balancer IP address

## Cleaning Up

To remove all resources created by Terraform, run:

```bash
terraform destroy
```

## Additional Documentation

For more detailed information on each module and configuration, refer to the documentation in the `docs` directory and the README files in each module.

## Contributing

If you would like to contribute to this project, please submit a pull request or open an issue for discussion.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.