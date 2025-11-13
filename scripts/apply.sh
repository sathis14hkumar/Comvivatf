#!/bin/bash

set -e

# Navigate to the environment directory
cd ../environments/test

# Initialize Terraform
terraform init

# Apply the Terraform configuration
terraform apply -auto-approve

# Navigate back to the original directory
cd ../../scripts