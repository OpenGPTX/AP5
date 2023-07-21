#!/bin/bash

if [ -z `printenv IONOS_TOKEN` ]; then
    echo "Stopping because IONOS_TOKEN is undefined"
    exit 1
fi  

# This script is used to build the cloud landscape for the federated catalogue.
terraform init && terraform refresh && terraform plan && terraform apply -auto-approve
