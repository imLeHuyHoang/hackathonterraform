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

variable "deployment_packages_prefix" {
  description = "Prefix folder in S3 for deployment packages"
  type        = string
  default     = "deployment-packages/"
}

variable "logs_prefix" {
  description = "Prefix folder in S3 for server logs"
  type        = string
  default     = "logs/"
}
