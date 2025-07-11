# Root Module Outputs

# Foundation Module Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.foundation.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.foundation.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.foundation.public_subnet_ids
}

output "security_groups" {
  description = "Security group IDs"
  value = {
    default_sg     = module.foundation.default_security_group_id
    ec2_windows_sg = module.foundation.ec2_windows_security_group_id
    lambda_sg      = module.foundation.lambda_security_group_id
  }
}

# Storage Module Outputs
output "s3_buckets" {
  description = "S3 bucket information"
  value = {
    main_bucket_name      = module.storage.main_bucket_id
    main_bucket_arn       = module.storage.main_bucket_arn
    artifacts_bucket_name = module.storage.artifacts_bucket_id
    artifacts_bucket_arn  = module.storage.artifacts_bucket_arn
  }
}

output "s3_folder_structure" {
  description = "S3 folder prefixes"
  value = {
    raw_data_prefix            = module.storage.raw_data_prefix
    processed_data_prefix      = module.storage.processed_data_prefix
    deployment_packages_prefix = module.storage.deployment_packages_prefix
  }
}

# IAM Role ARNs
output "iam_roles" {
  description = "IAM role ARNs"
  value = {
    lambda_execution_role     = module.foundation.lambda_execution_role_arn
    ec2_instance_role         = module.foundation.ec2_instance_role_arn
    codepipeline_service_role = module.foundation.codepipeline_service_role_arn
    codedeploy_service_role   = module.foundation.codedeploy_service_role_arn
    eventbridge_service_role  = module.foundation.eventbridge_service_role_arn
  }
}
