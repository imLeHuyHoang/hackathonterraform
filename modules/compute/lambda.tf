# Compute Module - Lambda Functions

# Data Processor Lambda Function
resource "aws_lambda_function" "data_processor" {
  s3_bucket     = var.lambda_code_bucket_id
  s3_key        = var.lambda_deployment_package_key
  function_name = "${local.resource_prefix}-data-processor"
  role          = var.lambda_execution_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 600 # 10 minutes (maximum timeout)
  memory_size   = 1024
  architectures = ["x86_64"]

  environment {
    variables = {
      S3_BUCKET_NAME             = var.main_bucket_id
      RAW_DATA_PREFIX            = var.raw_data_prefix
      PROCESSED_DATA_PREFIX      = var.processed_data_prefix
      DEPLOYMENT_PACKAGES_PREFIX = var.deployment_packages_prefix
      GITHUB_REPO_URL            = var.github_repo_url
    }
  }

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-data-processor"
    Purpose = "Process vulnerability data and create deployment packages"
  })
}

# Lambda permission for S3 to invoke data processor
resource "aws_lambda_permission" "s3_invoke_data_processor" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.main_bucket_arn
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "data_processor_logs" {
  name              = "/aws/lambda/${aws_lambda_function.data_processor.function_name}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-data-processor-logs"
    Purpose = "Lambda function logs for data processing"
  })
}