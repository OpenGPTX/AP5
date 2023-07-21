variable "namespace" {
  default = "federated-catalogue"
}

variable "dns_zone" {
  default = "example.com"
}

resource "helm_release" "fc" {
  name       = "fc"

  repository = "../deployment/helm"
  chart      = "fc"

  namespace = var.namespace

  values = [
    "${file("../deployment/helm/fc/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0].host"
    value = "fc.${var.dns_zone}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc.${var.dns_zone}"
  }
  set {
    name  = "fc.keycloakAuthServerUrl"
    value = "https://fc-key-server.${var.dns_zone}"
  }
  set {
    name  = "fc.springSecurityOauth2ResourceserverJwtIssuerUri"
    value = "https://fc-key-server.${var.dns_zone}/realms/gaia-x"
  }
}

resource "helm_release" "demo-portal" {
  name       = "demo-portal"

  repository = "../deployment/helm"
  chart      = "demo-portal"

  namespace = var.namespace

  values = [
    "${file("../deployment/helm/demo-portal/values.yaml")}"
  ]

  wait = false

  set {
    name  = "ingress.hosts[0].host"
    value = "fc-demo-portal.${var.dns_zone}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc-demo-portal.${var.dns_zone}"
  }
  set {
    name = "demoPortal.keycloakIssuerUri"
    value = "https://fc-key-server.${var.dns_zone}/realms/gaia-x"
  }
}
