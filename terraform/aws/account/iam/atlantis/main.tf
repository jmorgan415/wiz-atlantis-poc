provider "aws" {
  region = var.config[terraform.workspace].region
  assume_role {
    role_arn     = "arn:aws:iam::${var.config[terraform.workspace].account_id}:role/${var.config[terraform.workspace].account_name}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}
