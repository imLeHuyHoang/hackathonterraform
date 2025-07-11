# Root Module Variables

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vulnerability-patching"
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
  description = "EC2 instance type for Windows servers"
  type        = string
  default     = "t2.large"
}

variable "windows_versions" {
  description = "List of Windows versions to deploy"
  type        = list(string)
  default = [
    "Windows Server 2016",
    "Windows Server 2019",
    "Windows Server 2022"
  ]
}
