#!/bin/bash

# Navigate to the environment directory
cd ../environments/test || exit

# Run Terraform plan
terraform plan -var-file=terraform.tfvars -out=tfplan

# Output the plan file location
echo "Terraform plan created at: tfplan"