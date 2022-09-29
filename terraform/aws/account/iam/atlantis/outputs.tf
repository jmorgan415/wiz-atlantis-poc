output "atlatis_role_name" {
  value = aws_iam_role.atlantis_deployer.name
}

output "atlantis_role_arn" {
  value = aws_iam_role.atlantis_deployer.arn
}
