output "s3_raw" {
    description = "Nome do bucket S3 para os dados brutos"
    value      =  aws_s3_bucket.bucket-pops-raw-certificacoes.bucket
}

output "s3_raw_arn" {
  value = aws_s3_bucket.bucket-pops-raw-certificacoes.arn
}

output "s3_trusted" {
  description = "Nome do bucket S3 para os dados trusted"
  value      =  aws_s3_bucket.bucket-pops-trusted-certificacoes.bucket
}

output "s3_trusted_arn" {
  value = aws_s3_bucket.bucket-pops-trusted-certificacoes.arn
}

output "sns_topic_certificados_arn" {
  description = "Nome do tópico SNS para certificados"
  value = aws_sns_topic.topic_certificados.arn
}

output "sns_topic_processamento_arn" {
  description = "Nome do tópico SNS para o processamento da ETL certificados"
  value = aws_sns_topic.topic_processamento.arn
}

