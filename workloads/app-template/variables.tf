variable "region" {
  type        = string
  description = "Workload deployment region."
}

variable "name_prefix" {
  type        = string
  description = "Application resource naming prefix."
}

variable "lambda_source_path" {
  type        = string
  description = "Path to Lambda source for packaging by terraform module."
}
