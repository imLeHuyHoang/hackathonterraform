# Storage Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline service role"
  type        = string
}

# Lambda function dependencies (will be passed from compute module)
variable "data_processor_lambda_arn" {
  description = "ARN of the data processor Lambda function"
  type        = string
  default     = ""
}

variable "package_creator_lambda_arn" {
  description = "ARN of the package creator Lambda function"
  type        = string
  default     = ""
}

variable "lambda_permission_for_s3_data_processor" {
  description = "Lambda permission resource for S3 to invoke data processor"
  type        = string
  default     = ""
}

variable "lambda_permission_for_s3_package_creator" {
  description = "Lambda permission resource for S3 to invoke package creator"
  type        = string
  default     = ""
}
