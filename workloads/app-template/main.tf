provider "aws" {
  region = local.effective_region
}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))

  effective_region             = coalesce(var.region, try(local.global_config.default_regions.app_template, null), try(local.global_config.default_region, null))
  effective_name_prefix        = coalesce(var.name_prefix, try(local.global_config.accounts.metadata.name_prefix, null))
  effective_lambda_source_path = coalesce(var.lambda_source_path, try(local.global_config.accounts.metadata.lambda_source_path, null))
}

module "app_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${local.effective_name_prefix}-handler"
  handler       = "index.handler"
  runtime       = "python3.12"
  source_path   = local.effective_lambda_source_path

  create_role = true
}
