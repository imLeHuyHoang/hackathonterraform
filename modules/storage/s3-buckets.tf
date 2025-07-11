# Storage Module - S3 Buckets Configuration

# Main S3 Bucket with folder structure
resource "aws_s3_bucket" "main" {
  bucket = "${local.resource_prefix}-vulnerability-data"
  
  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-vulnerability-data"
    Purpose     = "VulnerabilityData"
  })
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
  
  depends_on = [aws_s3_bucket.main]
}

# Bucket Server-side Encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # SSE-S3 with Amazon S3 managed keys
    }
  }
  
  depends_on = [aws_s3_bucket.main]
}

# Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  
  depends_on = [aws_s3_bucket.main]
}

# Create folder structure using objects
resource "aws_s3_object" "raw_data_folder" {
  bucket = aws_s3_bucket.main.id
  key    = "raw-vulnerability-data/"
  
  tags = merge(local.common_tags, {
    Purpose = "Raw vulnerability scan data storage"
  })
  
  depends_on = [
    aws_s3_bucket.main,
    aws_s3_bucket_versioning.main,
    aws_s3_bucket_server_side_encryption_configuration.main,
    aws_s3_bucket_public_access_block.main
  ]
}

resource "aws_s3_object" "processed_data_folder" {
  bucket = aws_s3_bucket.main.id
  key    = "processed-data/"
  
  tags = merge(local.common_tags, {
    Purpose = "Processed and analyzed vulnerability data"
  })
  
  depends_on = [
    aws_s3_bucket.main,
    aws_s3_bucket_versioning.main,
    aws_s3_bucket_server_side_encryption_configuration.main,
    aws_s3_bucket_public_access_block.main
  ]
}

resource "aws_s3_object" "deployment_packages_folder" {
  bucket = aws_s3_bucket.main.id
  key    = "deployment-packages/"
  
  tags = merge(local.common_tags, {
    Purpose = "Windows update deployment packages"
  })
  
  depends_on = [
    aws_s3_bucket.main,
    aws_s3_bucket_versioning.main,
    aws_s3_bucket_server_side_encryption_configuration.main,
    aws_s3_bucket_public_access_block.main
  ]
}

# Lambda Function Code Bucket
resource "aws_s3_bucket" "lambda_code" {
  bucket = "${local.resource_prefix}-lambda-code"
  
  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-lambda-code"
    Purpose     = "Lambda function deployment packages"
    Description = "Stores Lambda function ZIP files and layers"
  })
}

# Lambda code bucket versioning
resource "aws_s3_bucket_versioning" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id
  versioning_configuration {
    status = "Enabled"
  }
  
  depends_on = [aws_s3_bucket.lambda_code]
}

# Lambda code bucket encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # SSE-S3 with Amazon S3 managed keys
    }
  }
  
  depends_on = [aws_s3_bucket.lambda_code]
}

# Lambda code bucket public access block
resource "aws_s3_bucket_public_access_block" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  
  depends_on = [aws_s3_bucket.lambda_code]
}

# Upload existing lambda deployment package
resource "aws_s3_object" "lambda_deployment_package" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda-deployment.zip"
  source = "${path.root}/lamdafunction/new-lambda-deployment.zip"  # Updated path
  etag   = filemd5("${path.root}/lamdafunction/new-lambda-deployment.zip")  # Updated path
  
  tags = merge(local.common_tags, {
    Purpose = "Lambda function deployment package"
  })
  
  depends_on = [
    aws_s3_bucket.lambda_code,
    aws_s3_bucket_versioning.lambda_code,
    aws_s3_bucket_server_side_encryption_configuration.lambda_code,
    aws_s3_bucket_public_access_block.lambda_code
  ]
}

# Separate bucket for CodePipeline artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.resource_prefix}-pipeline-artifacts"
  
  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-pipeline-artifacts"
    Purpose     = "CodePipeline artifacts storage"
    Description = "Stores CodePipeline build and deployment artifacts"
  })
}

# Artifacts bucket configuration
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
  
  depends_on = [aws_s3_bucket.artifacts]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # SSE-S3 with Amazon S3 managed keys
    }
  }
  
  depends_on = [aws_s3_bucket.artifacts]
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  
  depends_on = [aws_s3_bucket.artifacts]
}

# Artifacts bucket lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  
  rule {
    id     = "artifacts_cleanup"
    status = "Enabled"
    
    filter {}
    
    expiration {
      days = 30
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
  
  depends_on = [
    aws_s3_bucket.artifacts,
    aws_s3_bucket_versioning.artifacts,
    aws_s3_bucket_server_side_encryption_configuration.artifacts,
    aws_s3_bucket_public_access_block.artifacts
  ]
}