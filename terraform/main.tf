terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "storage" {
  source = "./modules/storage"
  path_to_database_script = ""
  path_to_private_script = ""
  path_to_public_script = ""
}

module "ec2" {
  depends_on = [module.network]
  source                  = "./modules/compute/ec2"
  subnet_public_id        = module.network.subnet_public_id
  subnet_private_id       = module.network.subnet_private_id
  sg_public_pops_id       = module.network.sg_public_pops_id
  sg_private_pops_id      = module.network.sg_private_pops_id
  path_to_private_script  = var.path_to_private_script
  path_to_public_script   = var.path_to_public_script
  path_to_database_script = var.path_to_database_script
}

module "lambda" {
  source = "./modules/compute/lambda"
}
