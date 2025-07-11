# Compute Module Outputs

# Lambda Function Outputs
output "data_processor_function_name" {
  description = "Name of the data processor Lambda function"
  value       = aws_lambda_function.data_processor.function_name
}

output "data_processor_function_arn" {
  description = "ARN of the data processor Lambda function"
  value       = aws_lambda_function.data_processor.arn
}

# Lambda function ARNs
output "lambda_function_arns" {
  description = "List of all Lambda function ARNs"
  value = [
    aws_lambda_function.data_processor.arn
  ]
}

output "lambda_function_names" {
  description = "List of all Lambda function names"
  value = [
    aws_lambda_function.data_processor.function_name
  ]
}

# Lambda Permissions for S3
output "lambda_permission_for_s3_data_processor" {
  description = "Lambda permission resource for S3 to invoke data processor"
  value       = aws_lambda_permission.s3_invoke_data_processor.id
}

# CloudWatch Log Groups
output "log_group_names" {
  description = "CloudWatch log group names"
  value = {
    data_processor = aws_cloudwatch_log_group.data_processor_logs.name
  }
}