# ========================= Função Lambda para Upload ========================
resource "aws_lambda_function" "upload-to-raw" {
  function_name = "upload-to-raw"
  role          = "arn:aws:iam::848479655698:role/LabRole"
  handler       = "Handler.LambdaHandler::handleRequest"
  runtime       = "java17"

  filename      = "C:\\grupo_pops\\pops-api\\pipe-bucket\\target\\pipe-bucket-1.0-SNAPSHOT.jar"
  memory_size   = 512
  timeout       = 60
}

resource "aws_lambda_function_url" "url-upload-to-raw" {
  function_name = aws_lambda_function.upload-to-raw.function_name
  authorization_type = "NONE"
}

output "upload-to-raw-url" {
  description = "URL para acessar a função Lambda"
  value       = aws_lambda_function_url.url-upload-to-raw.function_url
}

# ========================= Função Lambda para ETL ========================

resource "aws_lambda_function" "pops_etl" {
  function_name = "popsEtl"
  role          = "arn:aws:iam::848479655698:role/LabRole"
  handler       = "rawToTrusted.lambda_handler"
  runtime       = "python3.10"
  filename      = "C:\\grupo_pops\\pops-api\\etl-python\\rawToTrusted.zip"
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      BUCKET_TRUSTED = "bucket-pops-trusted-certificacoes"
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pops_etl.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-pops-raw-certificacoes.arn
}

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.bucket-pops-raw-certificacoes.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pops_etl.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# ========================= Função Lambda para segregação de dados ========================
resource "aws_lambda_function" "pops_segregation" {
  function_name = "popsSegregation"
  role          = "arn:aws:iam::848479655698:role/LabRole"
  handler       = "dateHandling.lambda_handler"
  runtime       = "python3.10"
  filename      = "C:\\grupo_pops\\pops-api\\etl-python\\dateHandling.zip"
  timeout       = 60
  memory_size   = 128

  environment {
    variables = {
      BUCKET_TRUSTED = "bucket-pops-trusted-certificacoes"
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_segregation" {
  statement_id  = "AllowS3InvokeSegregation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pops_segregation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-pops-trusted-certificacoes.arn
}

resource "aws_s3_bucket_notification" "s3_trigger_segregation" {
  bucket = aws_s3_bucket.bucket-pops-trusted-certificacoes.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pops_segregation.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "limpo/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_segregation]
}
