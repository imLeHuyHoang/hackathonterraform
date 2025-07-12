# Storage Module Outputs

# Main S3 Bucket Outputs
output "main_bucket_id" {
  description = "ID of the main S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "main_bucket_arn" {
  description = "ARN of the main S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "main_bucket_domain_name" {
  description = "Domain name of the main S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

# Lambda Code Bucket Outputs
output "lambda_code_bucket_id" {
  description = "ID of the Lambda code S3 bucket"
  value       = aws_s3_bucket.lambda_code.id
}

output "lambda_code_bucket_arn" {
  description = "ARN of the Lambda code S3 bucket"
  value       = aws_s3_bucket.lambda_code.arn
}

output "lambda_deployment_package_key" {
  description = "S3 key of the Lambda deployment package"
  value       = aws_s3_object.lambda_deployment_package.key
}

# Artifacts S3 Bucket Outputs
output "artifacts_bucket_id" {
  description = "ID of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}

# Folder Paths
output "raw_data_prefix" {
  description = "S3 prefix for raw vulnerability data"
  value       = "raw-vulnerability-data/"
}

output "processed_data_prefix" {
  description = "S3 prefix for processed data"
  value       = "processed-data/"
}

output "deployment_packages_prefix" {
  description = "S3 prefix for deployment packages"
  value       = "deployment-packages/"
}

# All bucket ARNs for monitoring
output "all_bucket_arns" {
  description = "List of all S3 bucket ARNs"
  value = [
    aws_s3_bucket.main.arn,
    aws_s3_bucket.lambda_code.arn,
    aws_s3_bucket.artifacts.arn
  ]
}

output "main_bucket_name" {
  description = "Name of the main S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

