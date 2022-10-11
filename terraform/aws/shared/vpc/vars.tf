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

variable "eks_cluster_names" {
  description = "EKS cluster name"
  type        = list
  default     = []
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

variable "vpc_cidr_network" {
  description = "VPC CIDR prefix"
  type        = string
  default     = ""
}
