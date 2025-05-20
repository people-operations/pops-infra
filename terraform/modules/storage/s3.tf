resource "aws_s3_bucket" "bucket-pops-raw-certificacoes" {
  bucket = "bucket-pops-raw-certificacoes"

  tags = {
    Name = "bucket-pops-raw-certificacoes"
  }
}

resource "aws_s3_bucket" "bucket-pops-trusted-certificacoes" {
  bucket = "bucket-pops-trusted-certificacoes"

  tags = {
    Name = "bucket-pops-trusted-certificacoes"
  }
}

