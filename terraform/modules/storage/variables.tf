data "aws_caller_identity" "current" {}

locals {
  acc_id = data.aws_caller_identity.current.account_id
}

variable "emails_to_subscribe" {
  description = "Lista de e-mails para subscrever no tópico"
  type        = list(string)
  default     = []
}