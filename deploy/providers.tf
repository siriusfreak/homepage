provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "microk8s-cluster"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "microk8s-cluster"
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
}
