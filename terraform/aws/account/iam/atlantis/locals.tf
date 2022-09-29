locals {
  tags = {
    Terraform = "true"
    Workspace = "s3://wiz-demo-terraform-backend/terraform/aws/account/iam/atlantis/${terraform.workspace}"
  }
}
