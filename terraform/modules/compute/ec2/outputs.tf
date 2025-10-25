output "ec2_ids" {
  description = "IDs das EC2 públicas"
  value = concat(
    aws_instance.ec2_public_management[*].id,
    aws_instance.ec2_public_analysis[*].id
  )
}