provider "aws" {
  region = var.region
}

module "app_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.name_prefix}-handler"
  handler       = "index.handler"
  runtime       = "python3.12"
  source_path   = var.lambda_source_path

  create_role = true
}
