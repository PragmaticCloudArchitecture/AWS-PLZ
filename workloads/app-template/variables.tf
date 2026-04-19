variable "region" {
  type        = string
  description = "Workload deployment region."
  default     = null
  nullable    = true
}

variable "name_prefix" {
  type        = string
  description = "Application resource naming prefix."
  default     = null
  nullable    = true
}

variable "lambda_source_path" {
  type        = string
  description = "Path to Lambda source for packaging by terraform module."
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
