terraform {
  #required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }
}

# AWS
provider "aws" {
  region = var.region
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.account_name}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}
