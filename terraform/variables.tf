variable "gemini_token" {
  description = "Token de acesso à API Gemini"
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