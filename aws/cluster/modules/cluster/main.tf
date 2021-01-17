variable "config" {}

output "cluster_name" {
  value = var.config.cluster.name
}

locals {
  env     = var.config["env"]["name"]
  region  = var.config["region"]["location"]
  project = var.config["project"]["prefix"]
  cluster_name = var.config["cluster"]["name"]
}

provider "aws" {
  region = local.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  subnets         = var.private_subnets

  vpc_id = var.vpc_id

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "m5.large"
    }
    second = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t2.micro"
    }
    third = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t2.micro"
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn, aws_iam_policy.worker_policy_0.arn]
}

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

resource "aws_iam_policy" "worker_policy_0" {
  name        = "worker-policy-0"
  description = "Worker policy for the Cluster AutoScaler"

  policy = file("ClusterAutoScaler.json")
}
