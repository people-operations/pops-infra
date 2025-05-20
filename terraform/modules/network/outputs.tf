output "subnet_public_id" {
  value = aws_subnet.public.id
}

output "subnet_private_id" {
  value = aws_subnet.private.id
}

output "sg_public_pops_id" {
  value = aws_security_group.sg-public-pops.id
}

output "sg_private_pops_id" {
  value = aws_security_group.sg-private-pops.id
}

output "rt_private_association_pops_id" {
  value = aws_route_table_association.rt-private-association-pops.id
}