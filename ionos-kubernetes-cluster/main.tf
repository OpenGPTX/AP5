terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "= 6.3.5"
    }
    kubernetes = {}
  }
}

variable "ionos_api_url" {
  type    = string
  default = ""
}

variable "datacenter_name" {
  default = "Digital Ecosystems"
}

variable "datacenter_location" {
  default = "de/txl"
}

variable "kubernetes_cluster_name" {
  default = "federated-catalog"
}

variable "node_memory" {
  type = number
  default = 6144
}

variable "node_count" {
  type = number
  default = 1
}

variable "cores_count" {
  type = number
  default = 2
}

provider "ionoscloud" {
  endpoint = var.ionos_api_url
}

resource "ionoscloud_datacenter" "digital_ecosystems" {
  name                = var.datacenter_name
  location            = var.datacenter_location
  description         = ""
  sec_auth_protection = false
}

##### Managed IONOS K8S 
resource "ionoscloud_lan" "lan1" {
  datacenter_id = ionoscloud_datacenter.digital_ecosystems.id
  public        = true
  name          = "k8s-public-lan"
  lifecycle {
    create_before_destroy = true
  }
  timeouts {}
}

resource "ionoscloud_k8s_cluster" "kubernetes1" {
  name        = var.kubernetes_cluster_name
  k8s_version = "1.25.6"
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "09:00:00Z"
  }

  timeouts {
  }
}

resource "ionoscloud_k8s_node_pool" "pool2" {
  datacenter_id  = ionoscloud_datacenter.digital_ecosystems.id
  k8s_cluster_id = ionoscloud_k8s_cluster.kubernetes1.id
  name           = "pool2"
  k8s_version    = ionoscloud_k8s_cluster.kubernetes1.k8s_version
  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "03:01:04Z"
  }
  # auto_scaling {
  #   max_node_count = 2
  #   min_node_count = 1
  # }

  cpu_family        = "INTEL_SKYLAKE"
  availability_zone = "AUTO"
  storage_type      = "HDD"
  node_count        = var.node_count
  cores_count       = var.cores_count
  ram_size          = var.node_memory
  storage_size      = 20
  timeouts {}
}


## configure access to the Container Registry in the K8S cluster
data "ionoscloud_k8s_cluster" "kubernetes1" {
  id = ionoscloud_k8s_cluster.kubernetes1.id
}

resource "local_sensitive_file" "kubeconfig" {
  content  = yamlencode(jsondecode(data.ionoscloud_k8s_cluster.kubernetes1.kube_config))
  filename = "kubeconfig-ionos.yaml"
}
provider "kubernetes" {
  config_path    = "kubeconfig-ionos.yaml"
  config_context = "cluster-admin@federated-catalog"
}

provider "helm" {
  kubernetes {
    config_path    = "kubeconfig-ionos.yaml"
  }
}

resource "helm_release" "nginx-ingres" {
  name       = "nginx-ingress"

  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  namespace = "nginx-ingress"
  version    = "0.17.1"

  create_namespace = true

  depends_on = [
    local_sensitive_file.kubeconfig
  ]
}