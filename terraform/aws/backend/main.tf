provider "aws" {
  region = "us-east-2"
  assume_role {
    role_arn     = "arn:aws:iam::984186218765:role/wiz-demo-infra-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}
