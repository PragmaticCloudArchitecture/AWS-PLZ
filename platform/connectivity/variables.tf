variable "region" {
  type        = string
  description = "AWS region for the hub deployment."
  default     = null
  nullable    = true
}

variable "name_prefix" {
  type        = string
  description = "Resource naming prefix."
  default     = null
  nullable    = true
}

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR for hub VPC."
  default     = null
  nullable    = true

  validation {
    condition     = var.hub_vpc_cidr == null || can(cidrnetmask(var.hub_vpc_cidr))
    error_message = "hub_vpc_cidr must be a valid CIDR."
  }
}

variable "azs" {
  type        = list(string)
  description = "Availability zones used by the hub."
  default     = null
  nullable    = true
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for hub services."
  default     = null
  nullable    = true

  validation {
    condition     = var.private_subnet_cidrs == null || var.azs == null || length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs must include one CIDR per AZ."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs for egress/shared endpoints."
  default     = null
  nullable    = true

  validation {
    condition     = var.public_subnet_cidrs == null || var.azs == null || length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs must include one CIDR per AZ."
  }
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
