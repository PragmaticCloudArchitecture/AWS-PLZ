variable "region" {
  type        = string
  description = "AWS region for central monitoring resources."
}

variable "name_prefix" {
  type        = string
  description = "Resource naming prefix."
}

variable "cloudtrail_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudTrail logs."

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.cloudtrail_bucket_name))
    error_message = "cloudtrail_bucket_name must be a valid S3 bucket name."
  }
}

variable "enable_security_hub" {
  type        = bool
  description = "Enable Security Hub baseline."
  default     = true
}
