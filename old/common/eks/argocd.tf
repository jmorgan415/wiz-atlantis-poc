locals {
  argocd-manager-role        = "${var.config[terraform.workspace].cluster_name}-argocd-manager"
}

data "aws_iam_policy_document" "argocd_manager" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/*-argocd-deployer"]
  }
}

resource "aws_iam_policy" "argocd_manager" {
  name        = "argocd-manager"
  description = "Allow argocd to assume the argocd-deployer roles for various clusters"
  policy      = join("", data.aws_iam_policy_document.argocd_manager.*.json)
}

resource "aws_iam_role_policy_attachment" "argocd_manager" {
  role       = module.argocd_manager_role.this_iam_role_name
  policy_arn = join("", aws_iam_policy.argocd_manager.*.arn)
}

module "argocd_manager_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "3.4.0"

  # required inputs
  role_name = local.argocd-manager-role

  # if this is the cluster where argocd will be deployed, create this role
  create_role      = true
  role_description = "Allows Argo CD to manage all clusters"
  # only allow these 2 service accounts to assume this role
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:argocd:argocd-server",
    "system:serviceaccount:argocd:argocd-application-controller",
  ]
  provider_url = module.eks.cluster_oidc_issuer_url
  tags         = local.tags
}

# define an argocd deployer role for every cluster
data "aws_iam_policy_document" "argocd_deployer_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      # only the argocd role can assume this argocd deployer role
      identifiers = ["arn:aws:iam::${var.config[terraform.workspace].account_id}:role/${local.argocd-manager-role}"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "argocd_deployer" {
  name               = "${var.config[terraform.workspace].cluster_name}-argocd-deployer"
  assume_role_policy = data.aws_iam_policy_document.argocd_deployer_assume_role_policy.json
}
