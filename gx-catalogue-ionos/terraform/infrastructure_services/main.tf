variable "namespace" {
  default = "federated-catalogue"
}

# create kubernetes namespace resource
resource "kubernetes_namespace" "federated-catalogue" {
  metadata {
    name = var.namespace
  }
}

# install helm postgresql
resource "helm_release" "postgres" {
  name       = "postgres"

  repository = "../deployment/helm"
  chart      = "postgres"

  namespace = kubernetes_namespace.federated-catalogue.metadata[0].name

  values = [
    "${file("../deployment/helm/postgres/values.yaml")}"
  ]
}

# install helm keycloak
variable "dns_zone" {
  default = "example.com"
}
resource "time_sleep" "wait_30_seconds" {
  depends_on = [helm_release.postgres, helm_release.neo4j]
  create_duration = "30s"
}


variable "keycloak_admin_username" {
  description = "Keycloak administrator username"
  type        = string
  sensitive   = true
  default     = "admin"
}
variable "keycloak_admin_password" {
  description = "Keycloak administrator password"
  type        = string
  sensitive   = true
  default     = "admin"
}
resource "helm_release" "keycloak" {
  depends_on = [helm_release.postgres, helm_release.neo4j, time_sleep.wait_30_seconds]
  name       = "keycloak"

  repository = "../deployment/helm"
  chart      = "keycloak"

  namespace = kubernetes_namespace.federated-catalogue.metadata[0].name

  values = [
    "${file("../deployment/helm/keycloak/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0].host"
    value = "fc-key-server.${var.dns_zone}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc-key-server.${var.dns_zone}"
  }
  set {
    name  = "keycloak.federatedCatalogueClientRedirectUris[0]"
    value = "https://fc-demo-portal.${var.dns_zone}/*"
  }
  set {
    name  = "keycloak.hostname"
    value = "fc-key-server.${var.dns_zone}"
  }
  set {
    name  = "keycloak.adminUser"
    value = "${var.keycloak_admin_username}"
  }
  set {
    name  = "keycloak.adminPassword"
    value = "${var.keycloak_admin_password}"
  }
  set {
    name  = "image.tag"
    value = "23.0.7"
  }
}

# helm install -n federated-catalogue neo4j -f neo4j/values.yaml neo4j/neo4j
resource "helm_release" "neo4j" {
  name       = "neo4j"

  repository = "../deployment/helm"
  chart      = "neo4j"

  namespace = var.namespace

  values = [
    "${file("../deployment/helm/neo4j/values.yaml")}"
  ]
}