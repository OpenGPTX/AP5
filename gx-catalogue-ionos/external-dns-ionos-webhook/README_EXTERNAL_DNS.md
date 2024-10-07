Setup of External DNS Ionos Webhook, according to the README.md at URL:
https://github.com/ionos-cloud/external-dns-ionos-webhook

*Prerequisite - Zone registration*
Generate token via endpoint https://api.ionos.com/auth/v1/tokens/generate;
Create Zone for the domain(s) to be used in Ionos DNS API via:

    
    curl --location --request POST 'https://dns.de-fra.ionos.com/zones' \
    --header 'Authorization: Bearer tokenValue' \
    --header 'Content-Type: application/json' \
    --data-raw '{
    "properties":{
    "description": "desc",
    "enabled": true,
    "zoneName": "example-dataloft-ionos.de"
    }
    }'

*Prerequisite - Subdomain registration*
Register Subdomains in application https://mein.ionos.de

1. Add bitnami helm chart:


    helm repo add bitnami https://charts.bitnami.com/bitnami

2. Prepare Secret / SealedSecret named ionos-credentials based on the token generated via endpoint https://api.ionos.com/auth/v1/tokens/generate:
    
    
    kubectl create secret generic ionos-credentials --from-literal=api-key=':tokenName'

3. Set property 'zoneNameFilters' in file values.yaml and install helm chart
    
    
    helm install external-dns-ionos bitnami/external-dns -f values.yaml


4. Test:


    kubectl --namespace=default get pods -l "app.kubernetes.io/name=external-dns,app.kubernetes.io/instance=external-dns-ionos"
    k apply -f external-dns-ionos-webhook/echoserver_test_domain5.yaml

