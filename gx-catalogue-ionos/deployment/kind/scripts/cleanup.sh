#!/bin/bash

echo "Delete kind cluster"
# Delete the kind cluster
kind delete cluster --name federated-catalogue

echo "Cleanup hosts file"
# Clean up hosts file
sudo sed -i '/fc-key-server-balancer-service/d' /etc/hosts
sudo sed -i '/demo-portal/d' /etc/hosts

echo "Cleanup complete"
