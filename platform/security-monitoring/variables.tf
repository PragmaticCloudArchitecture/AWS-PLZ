variable "region" {
  type        = string
  description = "AWS region for central monitoring resources."
  default     = null
  nullable    = true
}

variable "name_prefix" {
  type        = string
  description = "Resource naming prefix."
  default     = null
  nullable    = true
}

variable "cloudtrail_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudTrail logs."
  default     = null
  nullable    = true

  validation {
    condition     = var.cloudtrail_bucket_name == null || can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.cloudtrail_bucket_name))
    error_message = "cloudtrail_bucket_name must be a valid S3 bucket name."
  }
}

variable "enable_security_hub" {
  type        = bool
  description = "Enable Security Hub baseline."
  default     = null
  nullable    = true
}

variable "global_config_file" {
  type        = string
  description = "Optional path to a root-level YAML config file."
  default     = ""

  validation {
    condition     = var.global_config_file == "" || fileexists(var.global_config_file)
    error_message = "global_config_file must point to an existing file."
  }
}
