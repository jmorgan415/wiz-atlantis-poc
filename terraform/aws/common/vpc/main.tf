# AWS Info
provider "aws" {
  region = var.config[terraform.workspace].region
  assume_role {
    role_arn     = "arn:aws:iam::${var.config[terraform.workspace].account_id}:role/${var.config[terraform.workspace].account_name}-atlantis-deployer"
    session_name = "ATLANTIS"
  }
}

# EKS tags
locals {
  eks_tags = {
    for name in var.config[terraform.workspace].eks_cluster_names:
      "kubernetes.io/cluster/${name}" => "shared"
  }
  vpc_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}"
  }
  public_subnet_tags = {
    Name                     = "${var.config[terraform.workspace].vpc_name}_public_subnet"
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    Name                              = "${var.config[terraform.workspace].vpc_name}_private_subnet"
    "kubernetes.io/role/internal-elb" = "1"
  }
  karpenter_tags = {
    for name in var.config[terraform.workspace].eks_cluster_names:
      "karpenter.sh/discovery" => "${name}"
  }
  private_sg_ingress_cidr_blocks = {
    "${var.config[terraform.workspace].vpc_name}" = [
      module.vpc.vpc_cidr_block
    ]
  }
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.config[terraform.workspace].vpc_name
  cidr = "${var.config[terraform.workspace].vpc_cidr_network}.0.0/16"

  azs              = ["${var.config[terraform.workspace].region}a", "${var.config[terraform.workspace].region}b", "${var.config[terraform.workspace].region}c"]
  public_subnets   = ["${var.config[terraform.workspace].vpc_cidr_network}.0.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.48.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.96.0/20"]
  private_subnets  = ["${var.config[terraform.workspace].vpc_cidr_network}.16.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.64.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.112.0/20"]
  database_subnets = ["${var.config[terraform.workspace].vpc_cidr_network}.32.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.80.0/20", "${var.config[terraform.workspace].vpc_cidr_network}.128.0/20"]

  enable_nat_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  default_network_acl_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_nacl"
  }

  nat_eip_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_nat_eip"
  }

  nat_gateway_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_nat_gw"
  }

  database_subnet_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_database_subnet"
  }

  private_route_table_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_private_rt"
  }

  private_subnet_tags = merge (
    local.eks_tags,
    local.private_subnet_tags,
    local.karpenter_tags
  )

  public_route_table_tags = {
    Name = "${var.config[terraform.workspace].vpc_name}_public_rt"
  }

  public_subnet_tags = merge (
    local.eks_tags,
    local.public_subnet_tags
  )
  
  vpc_tags = merge (
    local.eks_tags,
    local.vpc_tags
  )

  tags = {
    vpc       = var.config[terraform.workspace].vpc_name
    Terraform = "true"
  }
}

# Default security groups
module "default_public_sg" {
  source              = "terraform-aws-modules/security-group/aws"

  name                = "${var.config[terraform.workspace].vpc_name}_default_public_sg"
  description         = "Default security group for public subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp","http-80-tcp"]
  egress_rules        = ["all-all"] 
}

module "default_private_sg" {
  source              = "terraform-aws-modules/security-group/aws"

  name                = "${var.config[terraform.workspace].vpc_name}_default_private_sg"
  description         = "Default security group for private subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = toset(lookup(local.private_sg_ingress_cidr_blocks, var.config[terraform.workspace].vpc_name, [module.vpc.vpc_cidr_block]))
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"] 
}

module "default_database_sg" {
  source              = "terraform-aws-modules/security-group/aws"

  name                = "${var.config[terraform.workspace].vpc_name}_default_database_sg"
  description         = "Default security group for database subnet"
  vpc_id              = module.vpc.vpc_id

  ingress_cidr_blocks = toset(lookup(local.private_sg_ingress_cidr_blocks, var.config[terraform.workspace].vpc_name, [module.vpc.vpc_cidr_block]))
  ingress_rules       = ["postgresql-tcp","mysql-tcp","memcached-tcp","redis-tcp","mongodb-27017-tcp"]
  egress_rules        = ["all-all"] 
}
