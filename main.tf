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

# Compute Layer - Lambda Functions
module "compute" {
  source = "./modules/compute"
  
  project_name = var.project_name
  environment  = var.environment
  
  # Dependencies from foundation module
  lambda_execution_role_arn = module.foundation.lambda_execution_role_arn
  vpc_id                   = module.foundation.vpc_id
  lambda_security_group_id = module.foundation.lambda_security_group_id
  
  # Dependencies from storage module
  main_bucket_id                   = module.storage.main_bucket_id
  main_bucket_arn                  = module.storage.main_bucket_arn
  lambda_code_bucket_id            = module.storage.lambda_code_bucket_id
  lambda_deployment_package_key    = module.storage.lambda_deployment_package_key
  raw_data_prefix                  = module.storage.raw_data_prefix
  processed_data_prefix            = module.storage.processed_data_prefix
  deployment_packages_prefix       = module.storage.deployment_packages_prefix
  
  depends_on = [module.foundation, module.storage]
  
  win2016_ami_id = var.win2016_ami_id
  win2019_ami_id = var.win2019_ami_id
  win2022_ami_id = var.win2022_ami_id
  subnet_id = module.foundation.public_subnet_ids[0]
  security_group_ids = [module.foundation.ec2_windows_security_group_id]
  key_name         = "my-hackathon-key"
  public_key_path  = "${path.root}/my-ec2-key.pub"
  ec2_instance_role_name = module.foundation.ec2_instance_role_name

  
}

# Create S3 bucket notifications after Lambda functions are created
resource "aws_s3_bucket_notification" "main_bucket_notification" {
  bucket = module.storage.main_bucket_id
  
  # Lambda function trigger for raw vulnerability data (Excel files)
  lambda_function {
    lambda_function_arn = module.compute.data_processor_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw-vulnerability-data/"
    filter_suffix       = ".xlsx"
  }
  
  # EventBridge trigger for deployment packages (to trigger CodePipeline later)
  eventbridge = true
  
  depends_on = [
    module.compute.lambda_permission_for_s3_data_processor
  ]
}

# CICD
module "cicd" {
  source = "./modules/cicd"

  project_name = var.project_name
  environment  = var.environment
  eventbridge_service_role_arn = module.foundation.eventbridge_service_role_arn
  main_bucket_name = module.storage.main_bucket_name 
  artifacts_bucket_id = module.storage.artifacts_bucket_id
  deployment_packages_prefix = module.storage.deployment_packages_prefix

  codepipeline_service_role_arn = module.foundation.codepipeline_service_role_arn
  codedeploy_service_role_arn   = module.foundation.codedeploy_service_role_arn
}



