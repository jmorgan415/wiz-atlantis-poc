# Create s3 bucket
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "wiz-demo-atlantis-aws"
    Environment = "atlantis-demo"
  }
}
