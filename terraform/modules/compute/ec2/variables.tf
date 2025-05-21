variable "subnet_public_id" {
  description = "ID da subnet pública"
  type        = string
}

variable "subnet_private_id" {
  description = "ID da subnet privada"
  type        = string
}

variable "sg_public_pops_id" {
  description = "ID do security group público"
  type        = string
}

variable "sg_private_pops_id" {
  description = "ID do security group privado"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "key_pair_name_public" {
  type    = string
  default = "key-ec2-public-pops"
}

variable "key_pair_name_private" {
  type    = string
  default = "key-ec2-private-pops"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default = "t2.micro"
}

variable "path_to_public_script" {
  description = "Caminho local para o script privado"
  type        = string
}

variable "path_to_private_script" {
  description = "Caminho local para o script privado"
  type        = string
}

variable "path_to_database_script" {
  description = "Caminho local para o script do banco de dados"
  type        = string
}