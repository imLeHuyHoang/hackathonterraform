#main.tf in root directory

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Foundation Layer - Networking, IAM, Security
module "foundation" {
  source         = "./modules/foundation"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
}

# Storage Layer - S3 Buckets (simplified without KMS)
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment

  # Dependencies from foundation module (removed KMS variables)
  lambda_role_arn       = module.foundation.lambda_execution_role_arn
  codepipeline_role_arn = module.foundation.codepipeline_service_role_arn

  deployment_packages_prefix = var.deployment_packages_prefix

  depends_on = [module.foundation]
}

# CICD - Tạo trước để có CloudWatch Log Groups
module "cicd" {
  source = "./modules/cicd"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # S3 buckets
  main_bucket_name           = module.storage.main_bucket_id
  artifacts_bucket_id        = module.storage.artifacts_bucket_id
  deployment_packages_prefix = var.deployment_packages_prefix

  # IAM Roles
  codepipeline_service_role_arn = module.foundation.codepipeline_service_role_arn
  codedeploy_service_role_arn   = module.foundation.codedeploy_service_role_arn
  eventbridge_service_role_arn  = module.foundation.eventbridge_service_role_arn

  depends_on = [module.foundation, module.storage]
}

# Compute Layer - Lambda Functions (phụ thuộc vào CICD để có log groups)
module "compute" {
  source = "./modules/compute"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Lambda configuration
  lambda_execution_role_arn     = module.foundation.lambda_execution_role_arn
  vpc_id                        = module.foundation.vpc_id
  lambda_security_group_id      = module.foundation.lambda_security_group_id
  lambda_code_bucket_id         = module.storage.lambda_code_bucket_id
  lambda_deployment_package_key = module.storage.lambda_deployment_package_key
  main_bucket_id                = module.storage.main_bucket_id
  main_bucket_arn               = module.storage.main_bucket_arn
  raw_data_prefix               = var.raw_data_prefix
  processed_data_prefix         = var.processed_data_prefix
  deployment_packages_prefix    = var.deployment_packages_prefix
  github_repo_url               = var.github_repo_url

  # EC2 configuration  
  win2016_ami_id         = var.win2016_ami_id
  win2019_ami_id         = var.win2019_ami_id
  win2022_ami_id         = var.win2022_ami_id
  subnet_id              = module.foundation.public_subnet_ids[0]
  security_group_ids     = [module.foundation.ec2_windows_security_group_id]
  key_name               = var.key_name
  ec2_instance_role_name = module.foundation.ec2_instance_role_name
  ec2_instance_type      = var.ec2_instance_type

  depends_on = [module.foundation, module.storage, module.cicd]
}

# Khôi phục S3 bucket notification ở main.tf
resource "aws_s3_bucket_notification" "main_bucket_notification" {
  bucket = module.storage.main_bucket_id

  # Chỉ Lambda trigger cho Excel files (.xlsx)
  lambda_function {
    lambda_function_arn = module.compute.data_processor_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.raw_data_prefix
    filter_suffix       = ".xlsx"
  }

  # EventBridge cho deployment packages
  eventbridge = true

  depends_on = [
    module.compute.lambda_permission_for_s3_data_processor
  ]
}



