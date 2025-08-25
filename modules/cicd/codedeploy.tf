# CodeDeploy Applications
resource "aws_codedeploy_app" "win2016" {
  compute_platform = "Server"
  name             = "${local.resource_prefix}-win2016"

  tags = merge(local.common_tags, {
    Name           = "${local.resource_prefix}-win2016"
    WindowsVersion = "2016"
  })
}

resource "aws_codedeploy_app" "win2019" {
  compute_platform = "Server"
  name             = "${local.resource_prefix}-win2019"

  tags = merge(local.common_tags, {
    Name           = "${local.resource_prefix}-win2019"
    WindowsVersion = "2019"
  })
}

resource "aws_codedeploy_app" "win2022" {
  compute_platform = "Server"
  name             = "${local.resource_prefix}-win2022"

  tags = merge(local.common_tags, {
    Name           = "${local.resource_prefix}-win2022"
    WindowsVersion = "2022"
  })
}

# Deployment Group for Win2016
resource "aws_codedeploy_deployment_group" "win2016" {
  app_name              = aws_codedeploy_app.win2016.name
  deployment_group_name = "${local.resource_prefix}-win2016-deployment-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_filter {
    key   = "CodeDeployApp"
    type  = "KEY_AND_VALUE"
    value = "win2016"
  }

  ec2_tag_filter {
    key   = "Environment"
    type  = "KEY_AND_VALUE"
    value = var.environment
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}

# Deployment Group for Win2019
resource "aws_codedeploy_deployment_group" "win2019" {
  app_name              = aws_codedeploy_app.win2019.name
  deployment_group_name = "${local.resource_prefix}-win2019-deployment-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_filter {
    key   = "CodeDeployApp"
    type  = "KEY_AND_VALUE"
    value = "win2019"
  }

  ec2_tag_filter {
    key   = "Environment"
    type  = "KEY_AND_VALUE"
    value = var.environment
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}

# Deployment Group for Win2022
resource "aws_codedeploy_deployment_group" "win2022" {
  app_name              = aws_codedeploy_app.win2022.name
  deployment_group_name = "${local.resource_prefix}-win2022-deployment-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_filter {
    key   = "CodeDeployApp"
    type  = "KEY_AND_VALUE"
    value = "win2022"
  }

  ec2_tag_filter {
    key   = "Environment"
    type  = "KEY_AND_VALUE"
    value = var.environment
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}
