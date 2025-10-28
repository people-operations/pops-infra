output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = [for s in local.public_subnets : s]
}

output "private_subnet_id" {
  description = "IDs da subnet privada"
  value       = aws_subnet.private_c.id
}

output "sg_public_management_pops_id" {
  value = aws_security_group.sg-public-management-pops.id
}

output "sg_public_analysis_pops_id" {
  value = aws_security_group.sg-public-analysis-pops.id
}

output "sg_private_pops_id" {
  value = aws_security_group.sg-private-pops.id
}

output "public_route_table_association_ids" {
  description = "IDs das associações route table públicas"
  value       = { for k, assoc in aws_route_table_association.rt_public_association : k => assoc.id }
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.vpc-pops.id
}

output "security_groups_id_alb" {
  description = "IDs dos security groups do ALB"
  value       = [aws_security_group.sg_alb.id]
}