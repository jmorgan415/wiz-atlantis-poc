# AWS Info
provider "aws" {
  region = var.config[terraform.workspace].region
  assume_role {
    role_arn     = "arn:aws:iam::${var.config[terraform.workspace].account_id}:role/${var.config[terraform.workspace].account_name}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}

# Create s3 bucket
resource "aws_s3_bucket" "demo" {
  bucket = var.config[terraform.workspace].bucket_name
  acl    = "private"

  tags = {
    Name        = "wiz-demo-atlantis-aws"
    Environment = "atlantis"
  }
}
