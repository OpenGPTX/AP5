variable "namespace" {
  default = "federated-catalogue"
}

variable "dns_zone" {
  default = "example.com"
}

variable "demo_portal_image_tag" {
  default = "latest"
}

variable "fc_server_image_tag" {
  default = "latest"
}

variable "verification_semantics" {
  default = "true"
}

variable "verification_schema" {
  default = "true"
}

variable "verification_signatures" {
  default = "true"
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
  set {
    name = "image.tag"
    value = "${var.fc_server_image_tag}"
  }
  set {
    name = "fc.verification.semantics"
    value = "${var.verification_semantics}"
  }
  set {
    name = "fc.verification.schema"
    value = "${var.verification_schema}"
  }
  set {
    name = "fc.verification.signatures"
    value = "${var.verification_signatures}"
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
  set {
    name = "image.tag"
    value = "${var.demo_portal_image_tag}"
  }
}
