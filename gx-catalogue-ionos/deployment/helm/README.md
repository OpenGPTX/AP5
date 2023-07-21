# Helm charts

This directory contains required Helm charts and Helm values for the deployment of the Federated Catalogue.

## Manually deploying the Federated Catalogue to a Kubernetes cluster

The Federated Catalogue can be deployed to a Kubernetes cluster using the Helm charts in this directory.

### Requirements
- [Helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Kubernetes cluster](https://kubernetes.io/docs/setup/) with **cert-manager**, **NGINX-ingress**, and optionally **external-dns** installed

### Deploy

1. Install postgresql

```bash
helm install -n federated-catalogue postgres -f postgres/values.yaml postgres/ --create-namespace
```

2. Install keycloak

```bash
helm install -n federated-catalogue keycloak -f keycloak/values.yaml keycloak/ --create-namespace
```

3. Install neo4j

```bash
helm install -n federated-catalogue neo4j -f neo4j/values.yaml neo4j/ --create-namespace
```

4. Install the Federated Catalogue service

```bash
helm install -n federated-catalogue fc -f fc/values.yaml fc/ --create-namespace
```

5. Install the demo portal

```bash
helm install -n federated-catalogue demo-portal -f demo-portal/values.yaml demo-portal/ --create-namespace
```
