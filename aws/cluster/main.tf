variable "config" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "bmutziu-jenkins-s3storage"
    key = "network/terraform.tfstate"
    region = var.config.region.location
  }
}

module "cluster" {
  source = "./modules/cluster"
  config = var.config
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets
}

output "cluster_name" {
  value = var.config.cluster.name
}

output "eat_this" {
  value = var.config.eat.this
}
