# Locals
locals {
  name            = var.config[terraform.workspace].cluster_name
  cluster_version = var.config[terraform.workspace].cluster_version
  region          = var.config[terraform.workspace].region
  partition       = data.aws_partition.current.partition

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
