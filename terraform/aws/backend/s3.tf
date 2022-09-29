resource "aws_s3_bucket" "terraform_backend" {
    bucket              = "wiz-demo-terraform-backend"
    object_lock_enabled = true
    tags = {
        Name = "S3 Remote Terraform State Store for Atlantis"
    }
}

resource "aws_s3_bucket_versioning" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.bucket

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "atlantis" {
  bucket = aws_s3_bucket.terraform_backend.id
  policy = data.aws_iam_policy_document.atlantis.json
}

data "aws_iam_policy_document" "atlantis" {
  statement {
    principals {
      type        = "AWS"
      #identifiers = ["arn:aws:iam::652180284939:role/eks.sonder-infra-2.atlantis.atlantis-manager"]
      identifiers = ["arn:aws:iam::984186218765:root"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.terraform_backend.arn,
      "${aws_s3_bucket.terraform_backend.arn}/*",
    ]
  }
}
