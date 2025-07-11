# Terraform Backend Configuration
# Uncomment and configure when ready to use remote state

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "vulnerability-patching/terraform.tfstate"
#     region         = "ap-southeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
