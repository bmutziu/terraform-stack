terraform {
  backend "s3" {
    bucket         = "bmutziu-jenkins-s3storage"
    dynamodb_table = "bmutziu-dnmdb"
    encrypt        = true
    key            = "network/terraform.tfstate"
    region         = "eu-west-1"
  }
}
