# Rule cho Win2016
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2016" {
  name        = "${local.resource_prefix}-s3-create-win2016"
  description = "Trigger CodePipeline Win2016 when new zip is uploaded"
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": { "name": [var.main_bucket_name] },
      "object": { "key": [{ "prefix": "${var.deployment_packages_prefix}/windows-server-2016/" }] }
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_win2016" {
  rule     = aws_cloudwatch_event_rule.trigger_pipeline_win2016.name
  arn      = aws_codepipeline.win2016.arn
  role_arn = var.eventbridge_service_role_arn
}

# Rule cho Win2019
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2019" {
  name        = "${local.resource_prefix}-s3-create-win2019"
  description = "Trigger CodePipeline Win2019 when new zip is uploaded"
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": { "name": [var.main_bucket_name] },
      "object": { "key": [{ "prefix": "${var.deployment_packages_prefix}/windows-server-2019/" }] }
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_win2019" {
  rule     = aws_cloudwatch_event_rule.trigger_pipeline_win2019.name
  arn      = aws_codepipeline.win2019.arn
  role_arn = var.eventbridge_service_role_arn
}

# Rule cho Win2022
resource "aws_cloudwatch_event_rule" "trigger_pipeline_win2022" {
  name        = "${local.resource_prefix}-s3-create-win2022"
  description = "Trigger CodePipeline Win2022 when new zip is uploaded"
  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["Object Created"],
    "detail": {
      "bucket": { "name": [var.main_bucket_name] },
      "object": { "key": [{ "prefix": "${var.deployment_packages_prefix}/windows-server-2022/" }] }
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_win2022" {
  rule     = aws_cloudwatch_event_rule.trigger_pipeline_win2022.name
  arn      = aws_codepipeline.win2022.arn
  role_arn = var.eventbridge_service_role_arn
}
