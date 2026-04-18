variable "region" {
  description = "AWS region for API operations."
  type        = string
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
