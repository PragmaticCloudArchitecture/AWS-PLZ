variable "region" {
  type        = string
  description = "AWS region for shared services."
}

variable "name_prefix" {
  type        = string
  description = "Naming prefix for shared services."
}

variable "artifact_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name used for shared artifacts."
}
