provider "aws" {
  region = local.effective_region
}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))

  effective_region              = coalesce(var.region, try(local.global_config.default_regions.security_monitoring, null), try(local.global_config.default_region, null))
  effective_name_prefix         = coalesce(var.name_prefix, try(local.global_config.accounts.metadata.name_prefix, null))
  effective_cloudtrail_bucket_name = coalesce(var.cloudtrail_bucket_name, try(local.global_config.accounts.metadata.cloudtrail_bucket_name, null))
  effective_enable_security_hub = coalesce(var.enable_security_hub, try(local.global_config.features.enable_security_hub, null), true)
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = local.effective_cloudtrail_bucket_name
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid = "CloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid = "CloudTrailWrite"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_cloudwatch_log_group" "central" {
  name              = "/aws/plz/${local.effective_name_prefix}/central"
  retention_in_days = 365
}

resource "aws_iam_role" "cloudtrail_logs" {
  name = "${local.effective_name_prefix}-cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "${local.effective_name_prefix}-cloudtrail-logs-policy"
  role = aws_iam_role.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.central.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "org_trail" {
  name                          = "${local.effective_name_prefix}-org-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.central.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs.arn
  enable_log_file_validation    = true
}

resource "aws_config_configuration_recorder" "baseline" {
  name     = "${local.effective_name_prefix}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "baseline" {
  name           = "${local.effective_name_prefix}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id
}

resource "aws_config_configuration_recorder_status" "baseline" {
  name       = aws_config_configuration_recorder.baseline.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.baseline]
}

resource "aws_iam_role" "config" {
  name = "${local.effective_name_prefix}-config-recorder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_s3_delivery" {
  name = "${local.effective_name_prefix}-config-delivery-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketAcl"]
        Resource = [aws_s3_bucket.cloudtrail.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/*"]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_securityhub_account" "this" {
  count = local.effective_enable_security_hub ? 1 : 0
}
