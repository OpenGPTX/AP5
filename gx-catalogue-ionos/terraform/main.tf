terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "= 6.3.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "ionoscloud" {
  endpoint = var.ionos_api_url
}

variable "kubeconfig" {
  type = string
  default = "../terraform/kubeconfig-ionos.yaml"
}

provider "kubernetes" {
  config_path    = "${var.kubeconfig}"
}

provider "helm" {
  kubernetes {
    config_path    = "${var.kubeconfig}"
  }
}

provider "kubectl" {
  config_path    = "${var.kubeconfig}"
}

variable "dns_zone" {
  default = "example.com"
}

variable "namespace" {
  default = "federated-catalogue"
}

module "infrastructure_services" {
  source = "./infrastructure_services"

  dns_zone = "${var.dns_zone}"
}

module "federated_catalogue" {
  source = "./federated_catalogue"

  depends_on = [
    module.infrastructure_services
  ]

  dns_zone = "${var.dns_zone}"
  namespace = "${var.namespace}"
}