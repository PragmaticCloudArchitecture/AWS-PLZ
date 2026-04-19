variable "region" {
  type        = string
  description = "AWS region for shared services."
  default     = null
  nullable    = true
}

variable "name_prefix" {
  type        = string
  description = "Naming prefix for shared services."
  default     = null
  nullable    = true
}

variable "artifact_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name used for shared artifacts."
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
