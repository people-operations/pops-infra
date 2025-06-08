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
  emails_to_subscribe = [
    "miguel.asilva@sptech.school",
    "7482fda1-df38-471a-8110-f093fb9c2f08@emailhook.site"
    //"gyulia.piqueira@sptech.school",
    //"ruan.montanari@sptech.school",
    //"gabriel.nsilva@sptech.school",
    //"gabriel.soliveira@sptech.school",
    //"michelly.katayama@sptech.school"
  ]
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
