# Foundation Module - IAM Roles and Policies

# Lambda Execution Role
resource "aws_iam_role" "lambda_execution" {
  name = "${local.resource_prefix}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# Lambda Basic Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom Lambda S3 Access Policy (simplified without KMS)
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "${local.resource_prefix}-lambda-s3-policy"
  description = "Allows Lambda functions to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::${local.resource_prefix}-*",
          "arn:aws:s3:::${local.resource_prefix}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

# EC2 Instance Role
resource "aws_iam_role" "ec2_instance" {
  name = "${local.resource_prefix}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance" {
  name = "${local.resource_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance.name

  tags = local.common_tags
}

# SSM Managed Instance Core (for Systems Manager)
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Enhanced CodeDeploy Agent Policy for EC2 with CloudWatch
resource "aws_iam_policy" "ec2_codedeploy_agent" {
  name        = "${local.resource_prefix}-ec2-codedeploy-agent-policy"
  description = "Allows EC2 instances to work with CodeDeploy and send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.resource_prefix}-*",
          "arn:aws:s3:::${local.resource_prefix}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::aws-codedeploy-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::aws-codedeploy-*"
        ]
      },
      # CloudWatch permissions for logging
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # CloudWatch Agent permissions
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_agent" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = aws_iam_policy.ec2_codedeploy_agent.arn
}

# Add CloudWatch Agent policy attachment
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_agent" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# CodePipeline Service Role
resource "aws_iam_role" "codepipeline_service" {
  name = "${local.resource_prefix}-codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# CodePipeline Service Policy
resource "aws_iam_policy" "codepipeline_service" {
  name        = "${local.resource_prefix}-codepipeline-service-policy"
  description = "Policy for CodePipeline service role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.resource_prefix}-*",
          "arn:aws:s3:::${local.resource_prefix}-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "codepipeline_service" {
  role       = aws_iam_role.codepipeline_service.name
  policy_arn = aws_iam_policy.codepipeline_service.arn
}

# CodeDeploy Service Role
resource "aws_iam_role" "codedeploy_service" {
  name = "${local.resource_prefix}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# CodeDeploy Service Policy
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = aws_iam_role.codedeploy_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# EventBridge Role (for S3 to CodePipeline integration)
resource "aws_iam_role" "eventbridge_service" {
  name = "${local.resource_prefix}-eventbridge-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

# EventBridge Policy for CodePipeline
resource "aws_iam_policy" "eventbridge_codepipeline" {
  name        = "${local.resource_prefix}-eventbridge-codepipeline-policy"
  description = "Allows EventBridge to trigger CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codepipeline:StartPipelineExecution"
      ]
      Resource = "arn:aws:codepipeline:*:*:${local.resource_prefix}-*"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eventbridge_codepipeline" {
  role       = aws_iam_role.eventbridge_service.name
  policy_arn = aws_iam_policy.eventbridge_codepipeline.arn
}
