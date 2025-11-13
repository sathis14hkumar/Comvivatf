#!/bin/bash

# Validate Terraform configuration
terraform validate

# Check for formatting issues
terraform fmt -check

# Check for any potential issues
terraform plan -out=tfplan -detailed-exitcode

# Exit with the appropriate status code
if [ $? -eq 0 ]; then
    echo "Terraform configuration is valid."
    exit 0
elif [ $? -eq 2 ]; then
    echo "Terraform configuration has changes."
    exit 2
else
    echo "Terraform configuration is invalid."
    exit 1
fi