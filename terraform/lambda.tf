data "archive_file" "extract" {
  type = "zip"
  output_file_mode = "0666"
  source_file = "${path.module}/../src/extract.py"
  output_path = "${path.module}/../src/extract.zip"
}

data "archive_file" "transform" {
  type = "zip"
  output_file_mode = "0666"
  source_file = "${path.module}/../src/transform.py"
  output_path = "${path.module}/../src/transform.zip"
}

data "archive_file" "load" {
  type = "zip"
  output_file_mode = "0666"
  source_file = "${path.module}/../src/load.py"
  output_path = "${path.module}/../src/load.zip"
}


data "archive_file" "pg8000_layer" {
  type = "zip"
  output_file_mode = "0666"
  source_dir = "${path.module}/../layer"
  output_path = "${path.module}/../layer.zip"
}

data "archive_file" "sqlalchemy_layer" {
  type = "zip"
  output_file_mode = "0666"
  source_dir = "${path.module}/../sqlalchemy_layer"
  output_path = "${path.module}/../sqlalchemy_layer.zip"
}

resource "aws_lambda_layer_version" "pg8000_layer" {
  layer_name = "pg8000_layer"
  compatible_runtimes = ["python3.12"]
  s3_bucket = aws_s3_bucket.lambda_code_bucket.id
  s3_key = aws_s3_object.pg_8000_layer.key
}

resource "aws_lambda_layer_version" "sqlalchemy_layer" {
  layer_name = "sqlalchemy_layer"
  compatible_runtimes = ["python3.12"]
  s3_bucket = aws_s3_bucket.lambda_code_bucket.id
  s3_key = aws_s3_object.sqlalchemy_layer.key
}

resource "aws_lambda_function" "extract" {
  function_name = "extract"
  handler = "extract.lambda_handler"
  runtime = "python3.12"
  timeout = 60
  s3_bucket = aws_s3_bucket.lambda_code_bucket.id
  s3_key = aws_s3_object.extract_lambda.key
  role = aws_iam_role.lambda_role.arn
  layers = [aws_lambda_layer_version.pg8000_layer.arn]
  memory_size = 500
  environment {
    variables = {
      PG_HOST=var.PG_HOST
      PG_PORT=var.PG_PORT
      PG_DATABASE=var.PG_DATABASE
      PG_USER=var.PG_USER
      PG_PASSWORD=var.PG_PASSWORD
    }
  }
}

resource "aws_lambda_function" "transform" {
  function_name = "transform"
  handler = "transform.lambda_handler"
  runtime = "python3.12"
  timeout = 60
  s3_bucket = aws_s3_bucket.lambda_code_bucket.id
  s3_key = aws_s3_object.transform_lambda.key
  role = aws_iam_role.lambda_role.arn
  layers = ["arn:aws:lambda:eu-west-2:336392948345:layer:AWSSDKPandas-Python312:14"]
  memory_size = 500
}

resource "aws_lambda_function" "load" {
  function_name = "load"
  handler = "load.lambda_handler"
  runtime = "python3.11"
  timeout = 60
  s3_bucket = aws_s3_bucket.lambda_code_bucket.id
  s3_key = aws_s3_object.load_lambda.key
  role = aws_iam_role.lambda_role.arn
  layers = ["arn:aws:lambda:eu-west-2:336392948345:layer:AWSSDKPandas-Python311:18", aws_lambda_layer_version.sqlalchemy_layer.arn, aws_lambda_layer_version.pg8000_layer.arn]
  memory_size = 500
  environment {
    variables = {
      PG_HOST_DW=var.PG_HOST_DW
      PG_PORT=var.PG_PORT
      PG_DATABASE_DW=var.PG_DATABASE_DW
      PG_USER=var.PG_USER
      PG_PASSWORD_DW=var.PG_PASSWORD_DW
    }
  }
}
