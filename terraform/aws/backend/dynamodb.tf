resource "aws_dynamodb_table" "terraform_backend" {
    name           = "wiz_demo_terraform_backend"
    read_capacity  = 10
    write_capacity = 10
    hash_key       = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    tags = {
        "Name" = "DynamoDB Terraform State Lock Table"
    }
}
