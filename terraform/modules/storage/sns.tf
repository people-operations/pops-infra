resource "aws_sns_topic" "topic_certificados" {
  name         = "pops-certificados-${local.acc_id}"
  display_name = "POPS Gestão de Certificados"
}

resource "aws_sns_topic_subscription" "email_subscriptions_certificados" {
  for_each = toset(var.emails_to_subscribe)
  topic_arn = aws_sns_topic.topic_certificados.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic" "topic_processamento" {
  name         = "pops-reporte-processamento-${local.acc_id}"
  display_name = "POPS Reporte de Processamento"
}


resource "aws_sns_topic_subscription" "email_subscriptions_processamento" {
  for_each = toset(var.emails_to_subscribe)
  topic_arn = aws_sns_topic.topic_processamento.arn
  protocol  = "email"
  endpoint  = each.value
}