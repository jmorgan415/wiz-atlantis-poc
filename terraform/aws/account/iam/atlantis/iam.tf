##################
## Atlantis POD ##
##################
locals {
  atlantis-manager-role = "${var.config[terraform.workspace].eks_cluster_name}-atlantis-manager"
  account-id            = var.config[terraform.workspace].account_id
}

data "aws_eks_cluster" "this" {
  name = var.config[terraform.workspace].eks_cluster_name
}

data "aws_iam_policy_document" "atlantis_manager" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/*-atlantis-deployer"]
  }
}

resource "aws_iam_policy" "atlantis_manager" {
  name        = "atlantis-manager"
  description = "Allow atlantis to assume the atlantis-deployer roles for various clusters"
  policy      = join("", data.aws_iam_policy_document.atlantis_manager.*.json)
}

resource "aws_iam_role_policy_attachment" "atlantis_manager" {
  role       = module.atlantis_manager_role.this_iam_role_name
  policy_arn = join("", aws_iam_policy.atlantis_manager.*.arn)
}

data "aws_iam_policy_document" "secrets_manager" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    effect    = "Allow"
    resources = ["arn:aws:secretsmanager:*:*:secret:atlantis-*"]
  }
}

resource "aws_iam_policy" "secrets_manager" {
  name        = "secrets-manager"
  description = "Allow atlantis to get secrets from the atlantis* secrets"
  policy      = join("", data.aws_iam_policy_document.secrets_manager.*.json)
}

resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = module.atlantis_manager_role.this_iam_role_name
  policy_arn = join("", aws_iam_policy.secrets_manager.*.arn)
}

module "atlantis_manager_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "3.4.0"

  # required inputs
  role_name = local.atlantis-manager-role

  # if this is the cluster where atlantis will be deployed, create this role
  create_role      = true
  role_description = "Allows Atlantis to manage terraform resources"
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:atlantis:atlantis",
  ]
  provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags         = local.tags
}

####################
# ALL AWS ACCOUNTS #
####################
data "aws_iam_policy_document" "atlantis_deployer_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account-id}:role/${local.atlantis-manager-role}",
        "arn:aws:iam::${local.account-id}:role/OktaDeveloperRole",
        "arn:aws:iam::${local.account-id}:user/demoadmin"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "atlantis_deployer" {
  name               = "${var.config[terraform.workspace].account_name}-atlantis-deployer"
  assume_role_policy = data.aws_iam_policy_document.atlantis_deployer_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "atlantis_deployer_attach_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.atlantis_deployer.name
}
