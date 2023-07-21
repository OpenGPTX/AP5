#!/bin/bash

if [ -z `printenv TF_VAR_dns_zone` ]; then
    echo "Stopping because TF_VAR_dns_zone is undefined"
    exit 1
fi  

if [ -z `printenv DNS_TYPE` ]; then
    echo "Stopping because DNS_TYPE is undefined"
    exit 1
fi  

DNS_TYPE_values=("external-dns" "manual" "ionos_dnsaas")
found=false
for value in "${DNS_TYPE_values[@]}"
do
    if [ "$value" == "${DNS_TYPE}" ] ; then
        echo "${DNS_TYPE} is in the array"
        found=true
    fi
done
if [ $found == false ] ; then
    echo "Stopping because DNS_TYPE is not valid"
    exit 1
fi

if [ -z `printenv TF_VAR_kubeconfig` ]; then
    echo "Stopping because TF_VAR_kubeconfig is undefined"
    exit 1
fi  

# This script is used to build the cloud landscape for the federated catalogue.
terraform -chdir=terraform init && terraform -chdir=terraform refresh && terraform -chdir=terraform plan && terraform -chdir=terraform apply -auto-approve

if [ $DNS_TYPE == 'ionos_dnsaas' ]; then
    if [ -z `printenv IONOS_DNS_ZONE_ID` ]; then
        DNS_ZONE_ID=$(curl -X "POST" \
            -H "accept: application/json" \
            -H "Authorization: Bearer $IONOS_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{ \
                \"properties\": { \
                    \"description\": \"Federated Catalogue DNS zone\", \
                    \"enabled\": true, \
                    \"zoneName\": \"$TF_VAR_dns_zone\"
                } \
            }" \
            "https://dns.de-fra.ionos.com/zones" |jq -r '.id')
        
        if [ $? != 0 ]; then
            echo "DNS zone creation failed"
            exit 1
        fi
    else
        DNS_ZONE_ID=$IONOS_DNS_ZONE_ID
        echo "Zone ID: $DNS_ZONE_ID"
    fi

    INGRESS_CONTROLLER_IP=$(kubectl --kubeconfig=$TF_VAR_kubeconfig -n nginx-ingress get svc nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ $? != 0 ]; then
        echo "Getting ingress controller ip failed"
        exit 1
    fi

    curl -X "POST" \
        -H "accept: application/json" \
        -H "Authorization: Bearer $IONOS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{ \
            \"properties\": { \
                \"name\": \"fc\", \
                \"type\": \"A\", \
                \"content\": \"$INGRESS_CONTROLLER_IP\", \
                \"ttl\": 3600, \
                \"prio\": 0, \
                \"disabled\": false \
            } \
        }" \
        "https://dns.de-fra.ionos.com/zones/$DNS_ZONE_ID/records"

    if [ $? != 0 ]; then
        echo "DNS record creation failed"
        exit 1
    fi

    curl -X "POST" \
        -H "accept: application/json" \
        -H "Authorization: Bearer $IONOS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{ \
            \"properties\": { \
                \"name\": \"fc-demo-portal\", \
                \"type\": \"A\", \
                \"content\": \"$INGRESS_CONTROLLER_IP\", \
                \"ttl\": 3600, \
                \"prio\": 0, \
                \"disabled\": false \
            } \
        }" \
        "https://dns.de-fra.ionos.com/zones/$DNS_ZONE_ID/records"

    if [ $? != 0 ]; then
        echo "DNS record creation failed"
        exit 1
    fi

    curl -X "POST" \
        -H "accept: application/json" \
        -H "Authorization: Bearer $IONOS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{ \
            \"properties\": { \
                \"name\": \"fc-key-server\", \
                \"type\": \"A\", \
                \"content\": \"$INGRESS_CONTROLLER_IP\", \
                \"ttl\": 3600, \
                \"prio\": 0, \
                \"disabled\": false \
            } \
        }" \
        "https://dns.de-fra.ionos.com/zones/$DNS_ZONE_ID/records"

    if [ $? != 0 ]; then
        echo "DNS record creation failed"
        exit 1
    fi
fi
