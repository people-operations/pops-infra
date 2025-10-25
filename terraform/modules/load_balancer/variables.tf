variable "vpc_id" {
  description = "ID da VPC onde o ALB e o Target Group serão criados"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets públicas onde o ALB será criado"
  type        = list(string)
}

variable "ec2_ids" {
  description = "Lista de IDs das instâncias EC2 que serão registradas no Target Group"
  type        = list(string)
}

variable "security_groups_ids" {
  description = "Lista de IDs das subnets públicas onde o ALB será criado"
  type        = list(string)
}