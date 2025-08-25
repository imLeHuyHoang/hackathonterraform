# EventBridge Rules for triggering pipelines when deployment packages are uploaded

# EventBridge Rule for Win2016 deployment packages
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2016" {
  name        = "${local.resource_prefix}-s3-create-win2016"
  description = "Triggers Win2016 pipeline when deployment package is uploaded"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.main_bucket_name]
      }
      object = {
        key = ["${var.deployment_packages_prefix}windows-server-2016/latest-deployment.zip"]
      }
    }
  })

  tags = local.common_tags
}

# EventBridge Target for Win2016 pipeline
resource "aws_cloudwatch_event_target" "pipeline_win2016" {
  rule      = aws_cloudwatch_event_rule.trigger_pipeline_win2016.name
  target_id = "Win2016PipelineTarget"
  arn       = aws_codepipeline.win2016.arn
  role_arn  = var.eventbridge_service_role_arn
}

# EventBridge Rule for Win2019 deployment packages
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2019" {
  name        = "${local.resource_prefix}-s3-create-win2019"
  description = "Triggers Win2019 pipeline when deployment package is uploaded"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.main_bucket_name]
      }
      object = {
        key = ["${var.deployment_packages_prefix}windows-server-2019/latest-deployment.zip"]
      }
    }
  })

  tags = local.common_tags
}

# EventBridge Target for Win2019 pipeline
resource "aws_cloudwatch_event_target" "pipeline_win2019" {
  rule      = aws_cloudwatch_event_rule.trigger_pipeline_win2019.name
  target_id = "Win2019PipelineTarget"
  arn       = aws_codepipeline.win2019.arn
  role_arn  = var.eventbridge_service_role_arn
}

# EventBridge Rule for Win2022 deployment packages
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2022" {
  name        = "${local.resource_prefix}-s3-create-win2022"
  description = "Triggers Win2022 pipeline when deployment package is uploaded"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.main_bucket_name]
      }
      object = {
        key = ["${var.deployment_packages_prefix}windows-server-2022/latest-deployment.zip"]
      }
    }
  })

  tags = local.common_tags
}

# EventBridge Target for Win2022 pipeline
resource "aws_cloudwatch_event_target" "pipeline_win2022" {
  rule      = aws_cloudwatch_event_rule.trigger_pipeline_win2022.name
  target_id = "Win2022PipelineTarget"
  arn       = aws_codepipeline.win2022.arn
  role_arn  = var.eventbridge_service_role_arn
}
