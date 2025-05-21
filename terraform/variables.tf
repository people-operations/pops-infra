variable "path_to_public_script" {
  description = "Caminho local para o script privado"
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