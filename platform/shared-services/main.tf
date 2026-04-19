provider "aws" {
  region = local.effective_region
}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))

  effective_region               = coalesce(var.region, try(local.global_config.default_regions.shared_services, null), try(local.global_config.default_region, null))
  effective_name_prefix          = coalesce(var.name_prefix, try(local.global_config.accounts.metadata.name_prefix, null))
  effective_artifact_bucket_name = coalesce(var.artifact_bucket_name, try(local.global_config.accounts.metadata.artifact_bucket_name, null))
}

module "artifact_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = local.effective_artifact_bucket_name

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.shared.arn
      }
    }
  }
}

resource "aws_kms_key" "shared" {
  description             = "Shared services encryption key"
  deletion_window_in_days = 30
}
