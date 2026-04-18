provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = var.cloudtrail_bucket_name
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "central" {
  name              = "/aws/plz/${var.name_prefix}/central"
  retention_in_days = 365
}

resource "aws_iam_role" "cloudtrail_logs" {
  name = "${var.name_prefix}-cloudtrail-logs-role"

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
  name = "${var.name_prefix}-cloudtrail-logs-policy"
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
  name                          = "${var.name_prefix}-org-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.central.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs.arn
  enable_log_file_validation    = true
}

resource "aws_config_configuration_recorder" "baseline" {
  name     = "${var.name_prefix}-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "baseline" {
  name           = "${var.name_prefix}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.cloudtrail.id
}

resource "aws_config_configuration_recorder_status" "baseline" {
  name       = aws_config_configuration_recorder.baseline.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.baseline]
}

resource "aws_iam_role" "config" {
  name = "${var.name_prefix}-config-recorder-role"

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

resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0
}
