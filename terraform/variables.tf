variable "path_to_public_script" {
  description = "Caminho local para o script privado"
  type        = string
}

variable "path_to_backend_script" {
  description = "Caminho local para o script privado"
  type        = string
}

variable "path_to_public_data_analysis_script" {
  description = "Caminho local para o script de configuração de EC2 para analise de dados"
  type        = string
}

variable "path_to_grafana_script" {
  description = "Caminho local para o script de configuração de EC2 para Grafana"
  type        = string
}

variable "gemini_token" {
  description = "Token de acesso à API Gemini"
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