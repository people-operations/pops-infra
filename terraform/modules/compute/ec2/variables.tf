variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Subnets públicas para cada AZ"
  type        = list(string)
}

variable "private_subnet" {
  description = "Id subnet privada"
  type        = string
}

variable "sg_public_management_pops_id" {
  description = "ID do security group da instancia de gerenciamento de squads"
  type        = string
}

variable "sg_public_analysis_pops_id" {
  description = "ID do security group da instancia de analise de dados"
  type        = string
}

variable "sg_private_pops_id" {
  description = "ID do security group privado"
  type        = string
}

variable "key_pair_name_management_public" {
  type    = string
  default = "key-ec2-public-management-pops"
}

variable "key_pair_name_analysis_public" {
  type    = string
  default = "key-ec2-data-analysis-pops"
}

variable "key_pair_name_private" {
  type    = string
  default = "key-ec2-private-pops"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default = "t3.small"
}