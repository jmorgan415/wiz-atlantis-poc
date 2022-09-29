terraform {
  #required_version = "1.1.9"
  backend "s3" {
    bucket               = "wiz-demo-terraform-backend"
    workspace_key_prefix = "terraform/aws/common/vpc"
    key                  = "terraform.tfstate"
    region               = "us-east-2"
    dynamodb_table       = "wiz_demo_terraform_backend"
    role_arn             = "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"
    session_name         = "ATLANTIS"
  }
}
