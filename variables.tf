# Root Module Variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.31.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default = [
    "172.31.0.0/20",
    "172.31.16.0/20",
    "172.31.32.0/20"
  ]
}

# Compute Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c6in.large"
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ebs_volume_size" {
  description = "EBS root volume size in GB"
  type        = number
  default     = 60
}

# S3 Configuration
variable "raw_data_prefix" {
  description = "S3 prefix for raw vulnerability data"
  type        = string
  default     = "raw-vulnerability-data/"
}

variable "processed_data_prefix" {
  description = "S3 prefix for processed data"
  type        = string
  default     = "processed-data/"
}

variable "deployment_packages_prefix" {
  description = "S3 prefix for deployment packages"
  type        = string
  default     = "deployment-packages/"
}

variable "logs_prefix" {
  description = "S3 prefix for server logs"
  type        = string
  default     = "logs/"
}

# GitHub Configuration
variable "github_repo_url" {
  description = "GitHub repository URL for source code"
  type        = string
  default     = "https://github.com/imLeHuyHoang/vulnerability-scripts.git"
}

# Lambda Configuration
variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

# EC2 Windows AMI IDs
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

# EC2 SSH Key Pair Name
variable "key_name" {
  description = "Name for the EC2 key pair on AWS"
  type        = string
}


