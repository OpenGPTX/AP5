# 1. Install Kubernetes Cluster Core Services
Follow instruction from https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster.
Or use the packaged scripts.

```console
cd ionos-kubernetes-cluster
```
## 1.1 Edit .env file
```console
cp .env-template .env
```
Edit the file with the following content

```file
# Required configuration
export IONOS_TOKEN=''

# Optional configuration
export TF_VAR_datacenter_name='OpenGPT-X Dev'
export TF_VAR_kubernetes_cluster_name='dev'
```
## 1.2 Create the kubernetes cluster
```console
source .env && ./create-ionos-kubernetes.sh
```

## 1.2. Follow installation instruction for ionos-kubernetes-cluster
Use the prepared env file
```console
cp ionos-kubernetes-cluster.env ionos-kubernetes-cluster/.env 
```

## 1.3 Install Cert-Manager
```console
export KUBECONFIG=$(readlink -f kubeconfig-ionos.yaml)

helm repo add jetstack https://charts.jetstack.io
helm repo update
# Install CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
# Install cert-manager
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 \
  --create-namespace

# Create a ClusterIssuer
kubectl apply -f helm/cert-manager/cluster-issuer.yaml
```

# 2. Install Federated Catalogue Service
Follow instruction from https://github.com/Digital-Ecosystems/gx-catalogue-ionos.
Or use the packaged scripts.

```console
cd gx-catalogue-ionos
```

## 2.1 Edit .env file
```console
cp .env-template .env
```
Edit the file with the following content

```file
# Required configuration
export IONOS_TOKEN=''
export TF_VAR_dns_zone='opengpt-x.de'
export DNS_TYPE='manual'
export TF_VAR_kubeconfig=<path to the kubeconfig.yaml file>
```

## 2.2 Edit the keycloak adminpassword for security

In file gx-catalogue-ionos/deployment/helm/keycloak/values.yaml
Change the adminPassword.

## 2.3 Install the services
```console
source .env && ./deploy-catalog-services.sh
```

## 2.4 Create a gaia-x user
Go to https://fc-key-server.opengpt-x.de login with admin credentials.
Go to https://fc-key-server.opengpt-x.de/admin/master/console/#/create/user/gaia-x.
Create a user, give it a strong password, give it the Client Roles :
* federated-catalogue/Ro-MU-A
* federated-catalogue/Ro-MU-CA
* federated-catalogue/Ro-PA-A
* federated-catalogue/Ro-SD-A
Make sure no required actions is pending and email is verified.

## 2.5 Test the APIs
```console
ACCESS_TOKEN=$(
    curl -s \
    -d "client_id=federated-catalogue" \
    -d "client_secret=keycloak-client-secret" \
    -d "username=<USER>" \
    -d "password=<PASSWORD>" \
    -d "grant_type=password" \
    "https://fc-key-server.opengpt-x.de/realms/gaia-x/protocol/openid-connect/token" | jq '.access_token' | tr -d '"'
)
echo $ACCESS_TOKEN
```

```console
# get participants
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.opengpt-x.de/participants

# get users
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.opengpt-x.de/users

# get roles
curl -H "Authorization: Bearer $ACCESS_TOKEN" https://fc.opengpt-x.de/roles
```