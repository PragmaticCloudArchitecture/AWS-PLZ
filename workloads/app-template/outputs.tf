output "lambda_function_arn" {
  value       = module.app_lambda.lambda_function_arn
  description = "Application Lambda ARN."
}
