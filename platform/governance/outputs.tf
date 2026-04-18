output "root_id" {
  description = "Organization root ID."
  value       = local.root_id
}

output "organizational_unit_ids" {
  description = "Map of organizational unit IDs keyed by OU name."
  value       = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}

output "baseline_scp_id" {
  description = "Baseline SCP ID if enabled."
  value       = try(aws_organizations_policy.baseline_scp[0].id, null)
}
