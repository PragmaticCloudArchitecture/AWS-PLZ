variable "region" {
  type        = string
  description = "AWS region for the hub deployment."
}

variable "name_prefix" {
  type        = string
  description = "Resource naming prefix."
}

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR for hub VPC."

  validation {
    condition     = can(cidrnetmask(var.hub_vpc_cidr))
    error_message = "hub_vpc_cidr must be a valid CIDR."
  }
}

variable "azs" {
  type        = list(string)
  description = "Availability zones used by the hub."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs for hub services."

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "private_subnet_cidrs must include one CIDR per AZ."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs for egress/shared endpoints."

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs must include one CIDR per AZ."
  }
}
