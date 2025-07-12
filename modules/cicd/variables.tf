variable "project_name" {
  type = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "deployment_packages_prefix" {
  type = string
}

variable "artifacts_bucket_id" {
  type = string
}

variable "codepipeline_service_role_arn" {
  type = string
}

variable "codedeploy_service_role_arn" {
  type = string
}

variable "eventbridge_service_role_arn" {
  description = "ARN of EventBridge service role"
  type        = string
}

variable "main_bucket_name" {
  type = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}






