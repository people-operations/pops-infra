variable "s3_raw" {
  description = "Nome do bucket S3 para os dados brutos"
  type        = string
}

variable "s3_raw_arn" {
  description = "ARN do bucket S3 para os dados brutos"
  type        = string
}

variable "s3_trusted" {
  description = "Nome do bucket S3 para os dados trusted"
  type        = string
}

variable "s3_trusted_arn" {
  description = "ARN do bucket S3 para os dados trusted"
  type        = string
}

variable "sns_topic_certificados_arn" {
  description = "Nome do tópico SNS para certificados"
  type        = string
}

variable "sns_topic_processamento_arn" {
  description = "Nome do tópico SNS para o processamento da ETL certificados"
  type        = string
}

variable "path_to_popsToRaw_script" {
  description = "Caminho local para a função Lambda popsToRaw"
  type        = string
}

variable "path_to_popsToRawLote_script" {
  description = "Caminho local para a função Lambda popsToRawLote"
  type        = string
}

variable "path_to_popsEtl_script" {
  description = "Caminho local para a função Lambda popsEtl"
  type        = string
}

variable "path_to_popsSegregation_script" {
  description = "Caminho local para a função Lambda popsSegregation"
  type        = string
}

variable "path_to_popsNotification_script" {
  description = "Caminho local para a função Lambda popsNotification"
  type        = string
}