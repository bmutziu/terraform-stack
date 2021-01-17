variable "config" {}

locals {
  env     = var.config["env"]["name"]
  region  = var.config["region"]["location"]
  project = var.config["project"]["prefix"]
  cluster_name = var.config["cluster"]["name"]
}

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name                 = "bmutziu-vpc-0"
  cidr                 = "10.50.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.50.16.0/20", "10.50.32.0/20", "10.50.48.0/20"]
  public_subnets       = ["10.50.0.0/22", "10.50.4.0/22", "10.50.8.0/22"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
