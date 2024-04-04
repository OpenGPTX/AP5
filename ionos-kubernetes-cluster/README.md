# ionos-kubernetes-cluster
IONOS Kubernetes cluster configuration

Follow these instructions to create Kubernetes cluster on IONOS DCD with installed **cert-manager**, **NGINX ingress**, and **external-dns**.

## Requirements

Before you start deploying the Federated Catalogue, make sure you meet the requirements:
- IONOS DCD Account
- Terraform
- Bash
- Helm

## Configuration

Set environment variables


```sh
# copy .env-template to .env and set the values of the required parameters
cp .env-template .env

# edit .env and fill in all required parameters

# load the configuration
source .env
```

## Deploy

### 1. Create Kubernetes cluster

To create the necessary infrastructure run the script ```./create-ionos-kubernetes.sh``` in current directory. Terraform will generate the `kubeconfig-ionos.yaml` which contain the KUBECONFIG for the cluster. 
```sh
source .env && ./create-ionos-kubernetes.sh
```

### 1.1 Install ingress-controller

    helm install --replace -n nginx-ingress nginx-ingress ingress-nginx/ingress-nginx -f helm/ingress-controller/values.yaml --version 4.7.2 --create-namespace

### 2. cert-manager (optional)

```bash
export KUBECONFIG=$(readlink -f kubeconfig-ionos.yaml)

helm repo add jetstack https://charts.jetstack.io
helm repo update
# Install CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
# Install cert-manager
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 --create-namespace

# Create a ClusterIssuer
kubectl apply -f helm/cert-manager/cluster-issuer.yaml
```

### 3.  Install external-dns (optional)

To install the DNS service you must first create secret containing service account credentials for one of the providers ( AWS, GCP, Azure, ... ) and configure it in the values file - ```helm/external-dns/values.yaml```. After that install the service with helm.


```bash
# Configure provider and credentials in ./external-dns/values.yaml
vim ./external-dns/values.yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n external-dns external-dns bitnami/external-dns -f helm/external-dns/values.yaml --version 6.14.1 --create-namespace
```

## Known issues

- Certificates not being issued by cert-manager

Often the *cert-manager* can get stuck and doesn't issue certificates. There is a workaround by changing the type of the NGINX-Ingress service from `LoadBalancer` to `ClusterIP` and then back to `LoadBalancer`. This will trigger the *cert-manager* to issue the certificates.

```bash

## References

- Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)    
- Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)  