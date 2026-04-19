variable "region" {
  description = "AWS region for API operations."
  type        = string
  default     = null
  nullable    = true
}

variable "organizational_units" {
  description = "Map of OU names to optional parent OU IDs. Empty parent means root."
  type = map(object({
    parent_ou_id = optional(string)
  }))
  default = {}
}

variable "baseline_scp_json" {
  description = "Optional SCP policy document JSON for baseline guardrails."
  type        = string
  default     = ""
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
