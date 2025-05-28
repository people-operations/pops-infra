# ========================= Função Lambda para Upload =================================
data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "upload-to-raw" {
  function_name = "popsUploadToRaw"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "Handler.LambdaHandler::handleRequest"
  runtime       = "java17"

  filename      = var.path_to_popsToRaw_script
  memory_size   = 512
  timeout       = 60

  environment {
    variables = {
      BUCKET_NAME = var.s3_raw
    }
  }
}

resource "aws_lambda_function_url" "url-upload-to-raw" {
  function_name = aws_lambda_function.upload-to-raw.function_name
  authorization_type = "NONE"
}

output "upload-to-raw-url" {
  description = "URL para acessar a função Lambda de upload via json"
  value       = aws_lambda_function_url.url-upload-to-raw.function_url
}

# ========================= Função Lambda para Upload em Lote ========================
resource "aws_lambda_function" "upload-to-raw-csv" {
  function_name = "popsUploadToRawCsv"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "uploadToRaw.lambda_handler"
  runtime       = "python3.10"

  filename      = var.path_to_popsToRawLote_script
  memory_size   = 512
  timeout       = 60
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python310:23"]

  environment {
    variables = {
      API_JAVA_URL = aws_lambda_function_url.url-upload-to-raw.function_url
    }
  }
}

resource "aws_lambda_function_url" "url-upload-to-raw-csv" {
  function_name = aws_lambda_function.upload-to-raw-csv.function_name
  authorization_type = "NONE"
}

output "upload-to-raw-url-csv" {
  description = "URL para acessar a função Lambda de upload em lote via csv"
  value       = aws_lambda_function_url.url-upload-to-raw-csv.function_url
}


# ========================= Função Lambda para ETL ======================================

resource "aws_lambda_function" "pops_etl" {
  function_name = "popsEtl"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "rawToTrusted.lambda_handler"
  runtime       = "python3.10"
  filename      = var.path_to_popsEtl_script
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      BUCKET_ORIGEM = var.s3_raw
      BUCKET_DESTINO = var.s3_trusted
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pops_etl.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_raw_arn
}

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = var.s3_raw

  lambda_function {
    lambda_function_arn = aws_lambda_function.pops_etl.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# ========================= Função Lambda para segregação de dados ======================
resource "aws_lambda_function" "pops_dataHandling" {
  function_name = "popsSegregation"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "dateHandling.lambda_handler"
  runtime       = "python3.10"
  filename      = var.path_to_popsSegregation_script
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      BUCKET_ORIGEM = var.s3_trusted
      BUCKET_DESTINO = var.s3_trusted
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_dataHandling" {
  statement_id  = "AllowS3InvokeSegregation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pops_dataHandling.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_trusted_arn
}

# ========================= Função Lambda para notificação =============================
resource "aws_lambda_function" "pops_notification" {
  function_name = "popsNotification"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler       = "notification.lambda_handler"
  runtime       = "python3.10"
  filename      = var.path_to_popsNotification_script
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      BUCKET_ORIGEM = var.s3_trusted
      TOPIC_ARN = var.sns_topic_certificados_arn
      SNS_TOPIC_ARN = var.sns_topic_processamento_arn
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_notification" {
  statement_id  = "AllowS3InvokeNotification"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pops_notification.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_trusted_arn
}

# ========================= Trigger para s3 trusted ====================================
resource "aws_s3_bucket_notification" "s3_trigger_trusted" {
  bucket = var.s3_trusted

  lambda_function {
    lambda_function_arn = aws_lambda_function.pops_dataHandling.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "limpo/"
    filter_suffix       = ".csv"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.pops_notification.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${formatdate("YYYY", timestamp())}/${lower(formatdate("MMM", timestamp()))}"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_dataHandling,
    aws_lambda_permission.allow_s3_invoke_notification
  ]
}

