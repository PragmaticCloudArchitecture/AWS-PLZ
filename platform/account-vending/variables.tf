variable "region" {
  type        = string
  description = "AWS region for API operations."
}

variable "account_name" {
  type        = string
  description = "Display name for the vended account."

  validation {
    condition     = length(trimspace(var.account_name)) >= 3
    error_message = "account_name must be at least 3 characters."
  }
}

variable "account_email" {
  type        = string
  description = "Unique account email for AWS Organizations account creation."

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.account_email))
    error_message = "account_email must be a valid email address."
  }
}

variable "parent_ou_id" {
  type        = string
  description = "Target organizational unit ID for account placement."

  validation {
    condition     = can(regex("^ou-[a-z0-9]{4,32}-[a-z0-9]{8,32}$", var.parent_ou_id))
    error_message = "parent_ou_id must be a valid AWS Organizations OU ID."
  }
}

variable "baseline_tags" {
  type        = map(string)
  description = "Tags to apply to account vending metadata resources."
  default     = {}
}
