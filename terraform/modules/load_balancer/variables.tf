variable "vpc_id" {
  description = "ID da VPC onde o ALB e o Target Group serão criados"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets públicas onde o ALB será criado"
  type        = list(string)
}

variable "ec2_ids_management" {
  description = "IDs das instâncias EC2 do serviço de management (porta 8080)"
  type        = list(string)
}

variable "ec2_ids_analysis" {
  description = "IDs das instâncias EC2 do serviço de análise (portas 3000 e 8888)"
  type        = list(string)
}

variable "security_groups_id_alb" {
  description = "Security Groups do Load Balancer"
  type        = list(string)
}