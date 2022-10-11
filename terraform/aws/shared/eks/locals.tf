# Locals
locals {
  name            = var.cluster_name
  cluster_version = var.cluster_version
  region          = var.region
  partition       = data.aws_partition.current.partition

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
