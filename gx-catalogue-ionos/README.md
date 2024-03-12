***
# Federated Catalogue deployment

This repository contains instructions to install the GAIA-X Federated Catalogue on IONOS Cloud.

These are the services that are deployed:
- Demo Portal
- Federated Catalogue
- Keycloak
- Neo4j
- PostgreSQL
***

## Requirements

Before you start deploying the Federated Catalogue, make sure you meet the requirements:
- Terraform
- kubectl
- Docker
- Helm
- DNS server and domain name
- Kubernetes cluster with installed **cert-manager**, **NGINX ingress**, and **external-dns**

***

## Configuration
Set environment variables

```sh
# copy .env-template to .env and set the values of the required parameters
cp .env-template .env

# load the configuration
source .env
```
> Note: For production deployments, make sure you change the **client-secret** [gaia-x-realm.json](deployment/kind/keycloak/gaia-x-realm.json) to a more secure value.
***

## Deploy

### 1. Create Kubernetes cluster

Follow [these instructions](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) to create Kubernetes cluster with installed **cert-manager**, **NGINX ingress**, and optionally **external-dns**.

### 2. Install and configure `external-dns` (Optional)

Skip this step if you want to use Ionos DNS service.

If you don't have `external-dns` configured on your cluster, follow [these instructions](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) for **external-dns**.

### 3. Use Ionos DNS service (Optional)

In order to use the DNS service, you should have skipped step 2 and you will need NS record pointing to Ionos name servers

```
ns-ic.ui-dns.com
ns-ic.ui-dns.de
ns-ic.ui-dns.org
ns-ic.ui-dns.biz
```

You will also need to set ```DNS_TYPE``` variable to True:
```sh
export DNS_TYPE='ionos_dnsaas'
```
If you have DNS zone already configured set ```IONOS_DNS_ZONE_ID``` environment variable.

### 4. Install the Federated-Catalogue services

To install the other services run the script ```deploy-catalog-services.sh``` in ```terraform``` directory.

```sh
./deploy-catalog-services.sh
```

### 4. Create user

Open the Keycloak admin console in your browser ```https://fc-key-server.<DOMAIN>``` and login with ```admin/admin```. Navigate to ```https://fc-key-server.<DOMAIN>/admin/master/console/#/create/user/gaia-x```.

**Note:** Replace ```<DOMAIN>``` with the domain name you have set in the environment variable ```TF_VAR_dns_zone```.

Go to **Users** and click on **Add user**. Fill in the form and click on **Save**. Make sure "Email Verified" is set to **ON**.

Next click on **Credentials** and set a password for the user.

After that click on **Role Mappings**. On **Client Roles** dropdown select **federated-catalogue** and move **Ro-MU-A**, **Ro-MU-CA**, **Ro-PA-A**, and **Ro-SD-A** to **Assigned Roles**.

Logout from Keycloak.

### 5. Access the demo portal

Go to ```https://fc-demo-portal.<DOMAIN>``` and login with the user you have created in the previous step.

**Note:** Replace ```<DOMAIN>``` with the domain name you have set in the environment variable ```TF_VAR_dns_zone```.

### 6. Uninstall

To uninstall the federated-catalogue services run the script ```uninstall-catalog-services.sh```.

```sh
./uninstall-catalog-services.sh
```

***

### 7. Using the fc-server REST API

Get JWT token from keycloak
```sh
# Note: replace the capitalized values with your own values
ACCESS_TOKEN=$(
    curl -s \
    -d "client_id=federated-catalogue" \
    -d "client_secret=keycloak-client-secret" \
    -d "username=<USERNAME>" \
    -d "password=<PASSWORD>" \
    -d "grant_type=password" \
    "https://fc-key-server.<DOMAIN>/realms/gaia-x/protocol/openid-connect/token" | jq '.access_token' | tr -d '"'
)
echo $ACCESS_TOKEN
```

Call the fc-server REST API
```sh
# get participants
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.<DOMAIN>/participants

# get users
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.<DOMAIN>/users

# get roles
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.<DOMAIN>/roles
```

## Example requests

### Get an Access Token from Keycloak

```sh
curl  -d "client_id=federated-catalogue" -d "client_secret=keycloak-client-secret" -d "username=<USERNAME>" -d 'password=<PASSWORD>' -d "grant_type=password" "https://<KEY-SERVER>/realms/gaia-x/protocol/openid-connect/token"
```

### Create a schema

```sh
curl -X 'POST' \
  'https://<KEY-SERVER>/schemas' \
  -H 'accept: */*' \
  -H 'Content-Type: application/rdf+xml' \
  -H 'Authorization: Bearer <ACCESS-TOKEN>' \
  -d @./examples/legal-personShape.ttl
```

### Create a legal person

```sh
curl -X 'POST' \
  'https://<KEY-SERVER>/participants' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <ACCESS-TOKEN>' \
  -d @./examples/legalPerson.jsonld
```

### Create a service offering

**WARNING** Make sure validations for `semantics`, `schema` and `signatures` are turned on in the `federated-catalogue` deployment.

```sh
curl -X 'POST' \
  'https://<KEY-SERVER>/self-descriptions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <ACCESS-TOKEN>' \
  -d @./examples/serviceOffering.jsonld
```

### Known issues

- Installation fails due to remaining 'keyclaok' Postgres database. 
```
To fix this, delete the database, uninstall and re-run the installation script.
```
- Services take too long to start. 
```
Check if DNS records have propagated. It could take a while 30-60 minutes for the DNS records to propagate.
```

### References

- GAIA-X [Federated Catalogue](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/fc-service-server)  
- Federated Catalogue [WIKI](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/wikis/home)
- Federated Catalogue fc-service [REST API](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/blob/main/openapi/fc_openapi.yaml)
- [IONOS Kubernetes cluster provisioning on DCD](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster)  
- GAIA-X [Demo Portal](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/demo-portal) application  
- [Keycloak](https://www.keycloak.org/)  
- [Neo4j](https://neo4j.com/)  
- [PostgreSQL](https://www.postgresql.org/)  
- Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)    
- Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)  