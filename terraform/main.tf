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
/*
module "storage" {
  source = "./modules/storage"
  emails_to_subscribe = [
    "miguel.asilva@sptech.school",
    "gyulia.piqueira@sptech.school",
    "ruan.montanari@sptech.school",
    "gabriel.nsilva@sptech.school",
    "gabriel.soliveira@sptech.school",
    "michelly.katayama@sptech.school"
  ]
}
*/

module "ec2" {
  depends_on                          = [module.network]
  source                              = "./modules/compute/ec2"
  public_subnets                      = module.network.public_subnet_ids
  private_subnet                      = module.network.private_subnet_id
  sg_public_management_pops_id        = module.network.sg_public_management_pops_id
  sg_public_analysis_pops_id          = module.network.sg_public_analysis_pops_id
  sg_private_pops_id                  = module.network.sg_private_pops_id
  path_to_private_script              = var.path_to_private_script
  path_to_public_script               = var.path_to_public_script
  path_to_public_data_analysis_script = var.path_to_public_data_analysis_script
  path_to_database_script             = var.path_to_database_script
}

module "load_balancer" {
  depends_on          = [module.ec2, module.network]
  source              = "./modules/load_balancer"
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.public_subnet_ids
  security_groups_ids = module.network.security_groups_ids
  ec2_ids             = module.ec2.ec2_ids
}
/*
module "lambda" {
  depends_on = [module.storage]
  source = "./modules/compute/lambda"

  s3_raw = module.storage.s3_raw
  s3_trusted = module.storage.s3_trusted

  s3_raw_arn = module.storage.s3_raw_arn
  s3_trusted_arn = module.storage.s3_trusted_arn

  sns_topic_certificados_arn = module.storage.sns_topic_certificados_arn
  sns_topic_processamento_arn = module.storage.sns_topic_processamento_arn

  path_to_popsEtl_script = var.path_to_popsEtl_script
  path_to_popsNotification_script = var.path_to_popsNotification_script
  path_to_popsSegregation_script = var.path_to_popsSegregation_script
  path_to_popsToRaw_script = var.path_to_popsToRaw_script
  path_to_popsToRawLote_script = var.path_to_popsToRawLote_script
}

 */

