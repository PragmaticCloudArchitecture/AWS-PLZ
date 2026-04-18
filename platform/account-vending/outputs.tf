output "account_id" {
  description = "Vended account ID."
  value       = aws_organizations_account.spoke.id
}

output "account_arn" {
  description = "Vended account ARN."
  value       = aws_organizations_account.spoke.arn
}
