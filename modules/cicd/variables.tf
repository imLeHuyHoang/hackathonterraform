variable "project_name" {
  type = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type = string
}

# variable "main_bucket_id" {
#   type = string
# }

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
  description = "ARN of EventBridge IAM Role"
  type        = string
}

variable "main_bucket_name" {
  type = string
}






