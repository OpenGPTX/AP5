#!/bin/bash

# Check if all requirements are installed
if ! command -v kind &> /dev/null
then
    echo "kind could not be found"
    exit
fi

if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

if ! command -v docker &> /dev/null
then
    echo "docker could not be found"
    exit
fi

# clean old installation
scripts/cleanup.sh

# Create a kind cluster
kind create cluster --name federated-catalogue
kubectl apply -f ./metalLB/metalLB-native.yaml
kubectl wait --for=condition=available --timeout=600s deployment -n metallb-system controller
kubectl apply -f ./metalLB/metalLB.yaml
kubectl create namespace federated-catalogue

# Create the manifests
kubectl apply -f ./manifests/postgres/
kubectl apply -f ./manifests/neo4j/
kubectl apply -f ./manifests/keycloak/
kubectl apply -f ./manifests/fc/
kubectl apply -f ./manifests/demo-portal

# Update hosts file
echo "$(kubectl get svc -n federated-catalogue fc-demo-portal-balancer-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}') demo-portal" | sudo tee -a /etc/hosts
echo "$(kubectl get svc -n federated-catalogue fc-key-server-balancer-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}') fc-key-server-balancer-service" | sudo tee -a /etc/hosts

# Import the gaia-x realm
KEYCLOAK_POD=$(kubectl get pods -n federated-catalogue -l app=fc-key-server -o jsonpath='{.items[0].metadata.name}')
# Wait for keycloak to be ready
kubectl wait --for=condition=ready --timeout=600s pod -n federated-catalogue $KEYCLOAK_POD
cat keycloak/gaia-x-realm.json | kubectl exec -i $KEYCLOAK_POD -n federated-catalogue -- /bin/sh -c "cat > /tmp/gaia-x-realm.json"
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/ --realm master --user admin --password admin
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh create realms -f /tmp/gaia-x-realm.json

# Create a user
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/ --realm master --user admin --password admin
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh create users -r gaia-x -s username=user -s enabled=true -s firstName=user -s lastName=user -s "email=user@example.com" -s emailVerified=true
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh add-roles -r gaia-x --uusername user --rolename Ro-MU-A --rolename Ro-MU-CA --rolename Ro-PA-A --rolename Ro-SD-A --cclientid federated-catalogue
kubectl exec $KEYCLOAK_POD -n federated-catalogue -- /opt/keycloak/bin/kcadm.sh set-password -r gaia-x --username user --new-password Userpassw0rd!

# Restart the demo portal and fc
kubectl rollout restart deployment -n federated-catalogue fc-demo-portal
kubectl rollout restart deployment -n federated-catalogue fc-service

# Wait for the demo portal to be ready
DEMO_PORTAL_POD=$(kubectl get pods -n federated-catalogue -l app=fc-demo-portal -o jsonpath='{.items[0].metadata.name}')
kubectl wait --for=condition=ready --timeout=600s pod -n federated-catalogue $DEMO_PORTAL_POD

echo "----------------------------------"

# Keycloak address
echo "Keycloak: http://fc-key-server-balancer-service:8080"
echo "username: admin"
echo "password: admin"

echo "----------------------------------"

# Demo portal address
echo "Demo portal: http://demo-portal:8088"
echo "username: user"
echo "password: Userpassw0rd!"


