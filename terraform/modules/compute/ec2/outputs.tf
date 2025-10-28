output "ec2_ids_analysis" {
  description = "IDs das EC2 gestão de squad"
  value =  aws_instance.ec2_public_analysis[*].id
}

output "ec2_ids_management" {
  description = "IDs das EC2 gestão de squad"
  value = aws_instance.ec2_public_management[*].id
}