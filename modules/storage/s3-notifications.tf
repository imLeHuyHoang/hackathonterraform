# # Storage Module - S3 Event Notifications

# # S3 bucket notification for triggering Lambda when raw data is uploaded
# resource "aws_s3_bucket_notification" "main_bucket_notification" {
#   bucket = aws_s3_bucket.main.id
  
#   # Lambda function trigger for raw vulnerability data (Excel/CSV files)
#   lambda_function {
#     lambda_function_arn = var.data_processor_lambda_arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "raw-vulnerability-data/"
#     filter_suffix       = ".xlsx"
#   }
  
#   lambda_function {
#     lambda_function_arn = var.data_processor_lambda_arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "raw-vulnerability-data/"
#     filter_suffix       = ".csv"
#   }
  
#   # Lambda function trigger for processed data (to create deployment packages)
#   lambda_function {
#     lambda_function_arn = var.package_creator_lambda_arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "processed-data/"
#     filter_suffix       = ".xlsx"
#   }
  
#   # EventBridge trigger for deployment packages (to trigger CodePipeline)
#   eventbridge = true
  
#   depends_on = [
#     var.lambda_permission_for_s3_data_processor,
#     var.lambda_permission_for_s3_package_creator
#   ]
# }
