output "cloudtrail_arn" {
  value       = aws_cloudtrail.org_trail.arn
  description = "Central trail ARN."
}

output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.central.arn
  description = "Central monitoring log group ARN."
}

output "security_hub_enabled" {
  value       = local.effective_enable_security_hub
  description = "Whether security hub baseline is enabled."
}
