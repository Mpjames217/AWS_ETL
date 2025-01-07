resource "aws_s3_bucket" "ingestion-bucket" {
  bucket = "ingestion-bucket-neural-normalisers-new"
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = "processed-bucket-neural-normalisers"
}

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket_prefix = "lambda-code-bucket"
}

resource "aws_s3_object" "extract_lambda" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key = "extract_lambda"
  source = "${path.module}/../src/extract.zip"
}

resource "aws_s3_object" "transform_lambda" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key = "transform_lambda"
  source = "${path.module}/../src/transform.zip"
}

resource "aws_s3_object" "load_lambda" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key = "load_lambda"
  source = "${path.module}/../src/load.zip"
}

resource "aws_s3_object" "pg_8000_layer" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key = "pg_8000_layer"
  source = "${path.module}/../layer.zip"
}

resource "aws_s3_object" "sqlalchemy_layer" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key = "sqlalchemy_layer"
  source = "${path.module}/../sqlalchemy_layer.zip"
}