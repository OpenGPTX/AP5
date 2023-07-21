#!/bin/bash

if [ -z `printenv TF_VAR_dns_zone` ]; then
    echo "Stopping because TF_VAR_dns_zone is undefined"
    exit 1
fi  

if [ -z `printenv DNS_TYPE` ]; then
    echo "Stopping because DNS_TYPE is undefined"
    exit 1
fi  

if [ -z `printenv TF_VAR_kubeconfig` ]; then
    echo "Stopping because TF_VAR_kubeconfig is undefined"
    exit 1
fi  

# This script is used to build the cloud landscape for the federated catalogue.
terraform -chdir=terraform destroy -auto-approve

if [ $DNS_TYPE == 'ionos_dnsaas' ]; then
    if [ -z `printenv IONOS_DNS_ZONE_ID` ]; then
        DNS_ZONE_ID=$(curl -X "GET" \
    -H "accept: application/json" \
    -H "Authorization: Bearer $IONOS_TOKEN" \
    -H "Content-Type: application/json" \
    "https://dns.de-fra.ionos.com/zones" |jq -r ".items[] | select(.properties[\"zoneName\"] == \"$TF_VAR_dns_zone\") | .id")
        
        if [ $? != 0 ]; then
            echo "Getting zone id failed"
            exit 1
        fi
    else
        DNS_ZONE_ID=$IONOS_DNS_ZONE_ID
    fi

    curl -X "DELETE" \
        -H "accept: application/json" \
        -H "Authorization: Bearer $IONOS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dns.de-fra.ionos.com/zones/$DNS_ZONE_ID"

    if [ $? != 0 ]; then
        echo "DNS zone deletion failed"
        exit 1
    else
        echo "DNS zone $DNS_ZONE_ID deleted"
    fi

fi

