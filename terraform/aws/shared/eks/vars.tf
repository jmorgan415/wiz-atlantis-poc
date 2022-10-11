variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

variable "account_name" {
  description = "AWS account name"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster version"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = ""
}
