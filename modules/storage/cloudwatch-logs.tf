# # CloudWatch Log Groups for Lambda Functions

# resource "aws_cloudwatch_log_group" "data_processor_lambda" {
#   name              = "/aws/lambda/${local.resource_prefix}-data-processor"
#   retention_in_days = 14
#   # Tạm thời bỏ KMS encryption cho CloudWatch Logs
#   # kms_key_id        = var.kms_key_id

#   tags = merge(local.common_tags, {
#     Name    = "${local.resource_prefix}-data-processor-logs"
#     Purpose = "Lambda function logs"
#   })
# }

# resource "aws_cloudwatch_log_group" "package_creator_lambda" {
#   name              = "/aws/lambda/${local.resource_prefix}-package-creator"
#   retention_in_days = 14
#   # Tạm thời bỏ KMS encryption cho CloudWatch Logs
#   # kms_key_id        = var.kms_key_id

#   tags = merge(local.common_tags, {
#     Name    = "${local.resource_prefix}-package-creator-logs"
#     Purpose = "Lambda function logs"
#   })
# }

# resource "aws_cloudwatch_log_group" "s3_access_logs" {
#   name              = "/aws/s3/${local.resource_prefix}-access-logs"
#   retention_in_days = 30
#   # Tạm thời bỏ KMS encryption cho CloudWatch Logs
#   # kms_key_id        = var.kms_key_id

#   tags = merge(local.common_tags, {
#     Name    = "${local.resource_prefix}-s3-access-logs"
#     Purpose = "S3 access logging"
#   })
# }