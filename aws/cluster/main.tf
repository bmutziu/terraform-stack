variable "config" {}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
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
