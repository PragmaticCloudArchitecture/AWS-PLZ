provider "aws" {
  region = var.region
}

module "artifact_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = var.artifact_bucket_name

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_kms_key" "shared" {
  description             = "Shared services encryption key"
  deletion_window_in_days = 30
}
