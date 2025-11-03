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
  default = "t2.micro"
}

variable "path_to_public_script" {
  description = "Caminho local para o script de configração de EC2 de gerenciamento de squads"
  type        = string
}

variable "path_to_public_data_analysis_script" {
  description = "Caminho local para o script de configração de EC2 para analise de dados"
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

variable "path_to_grafana_script" {
    description = "Caminho local para o script de configuração do Grafana"
    type        = string
}

variable "path_to_backend_script" {
  description = "Caminho local para o script de configuração do Grafana"
  type        = string
}