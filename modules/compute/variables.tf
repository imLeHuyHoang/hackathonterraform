# Compute Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

# Dependencies from foundation module
variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda functions"
  type        = string
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda functions"
  type        = list(string)
  default     = [] # Empty means Lambda runs outside VPC
}

# Dependencies from storage module
variable "main_bucket_id" {
  description = "Main S3 bucket ID"
  type        = string
}

variable "main_bucket_arn" {
  description = "Main S3 bucket ARN"
  type        = string
}

variable "lambda_code_bucket_id" {
  description = "Lambda code S3 bucket ID"
  type        = string
}

variable "lambda_deployment_package_key" {
  description = "S3 key of the Lambda deployment package"
  type        = string
}

variable "raw_data_prefix" {
  description = "S3 prefix for raw vulnerability data"
  type        = string
}

variable "processed_data_prefix" {
  description = "S3 prefix for processed data"
  type        = string
}

variable "deployment_packages_prefix" {
  description = "S3 prefix for deployment packages"
  type        = string
}

# GitHub Configuration
variable "github_repo_url" {
  description = "GitHub repository URL for source code"
  type        = string
  # default     = "https://github.com/imLeHuyHoang/vulnerability-scripts.git"
}

# Lambda Configuration
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 600
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

#Ec2 config
variable "win2016_ami_id" {
  description = "AMI ID for Windows Server 2016"
  type        = string
}

variable "win2019_ami_id" {
  description = "AMI ID for Windows Server 2019"
  type        = string
}

variable "win2022_ami_id" {
  description = "AMI ID for Windows Server 2022"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.medium"
}

variable "subnet_id" {
  description = "Subnet ID for EC2"
  type        = string
}

variable "security_group_ids" {
  description = "List of SG IDs"
  type        = list(string)
}

variable "ec2_instance_role_name" {
  description = "IAM role name attached to EC2"
  type        = string
}

variable "key_name" {
  description = "Name for the EC2 key pair on AWS"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CodeDeploy agent installation"
  type        = string
  default     = "ap-southeast-1"
}