resource "aws_s3_bucket" "bucket-pops-raw-certificacoes" {
  bucket = "bucket-pops-raw-certificacoes-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Name = "bucket-pops-raw-certificacoes"
  }
}

resource "aws_s3_bucket" "bucket-pops-trusted-certificacoes" {
  bucket = "bucket-pops-trusted-certificacoes-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Name = "bucket-pops-trusted-certificacoes"
  }
}

