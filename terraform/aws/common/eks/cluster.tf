## Data
data "aws_partition" "current" {}

# # Used to get VPC info
# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#   config = {
#     bucket = "wiz-demo-terraform-backend"
#     key    = "terraform/aws/common/vpc/${var.config[terraform.workspace].vpc_workspace}/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

# # Used to get IAM info
# data "terraform_remote_state" "iam_atlantis" {
#   backend = "s3"
#   config = {
#     bucket = "wiz-demo-terraform-backend"
#     key    = "terraform/aws/account/iam/atlantis/${var.config[terraform.workspace].iam_atlantis_workspace}/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  
  # Encryption key
  create_kms_key = true
  cluster_encryption_config = [{
    resources = ["secrets"]
  }]
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  create_aws_auth_configmap       = true
  manage_aws_auth_configmap       = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::984186218765:role/OktaDeveloperRole"
      username = "oktadeveloperrole"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"
      username = "atlantis-deployer"
      groups   = ["system:masters"]
    },
    {
      rolearn  = aws_iam_role.argocd_deployer.arn
      username = "argocd-deployer"
      groups   = ["system:masters"]
    },
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::984186218765:user/demoadmin"
      username = "demoadmin"
      groups   = ["system:masters"]
    },
  ]

  enable_irsa = true

  vpc_id     = "vpc-04e3bfb05bd1c6be0"
  subnet_ids = ["subnet-069a8879c9077a64a", "subnet-0c708b3938723ca66", "subnet-07fb1026db7410842"]

  node_security_group_additional_rules = {
    # Control plane invoke Karpenter webhook
    ingress_karpenter_webhook_tcp = {
      description                   = "Control plane invoke Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.medium"]

      k8s_labels = {
        "purpose"     = "karpenter"
        "lifecycle"   = "managed"
        "performance" = "burstable"
      }

      min_size     = 2
      max_size     = 10
      desired_size = 2

      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

    }
  }

  # OIDC Identity provider
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
}
