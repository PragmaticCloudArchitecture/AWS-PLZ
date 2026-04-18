output "artifact_bucket_id" {
  value       = module.artifact_bucket.s3_bucket_id
  description = "Shared artifact bucket name."
}

output "shared_kms_key_arn" {
  value       = aws_kms_key.shared.arn
  description = "Shared KMS key ARN."
}
