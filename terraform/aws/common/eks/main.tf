# AWS
provider "aws" {
  region = var.config[terraform.workspace].region
  assume_role {
    role_arn     = "arn:aws:iam::${var.config[terraform.workspace].account_id}:role/${var.config[terraform.workspace].account_name}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}

# Helm
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--role", "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"]
    }
  }
}

# Kubectl
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--role", "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"]
    command     = "aws"
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--role", "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"]
    command     = "aws"
  }
}
