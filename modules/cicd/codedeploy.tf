# CodeDeploy Application
resource "aws_codedeploy_app" "windows_patch_app" {
  compute_platform = "Server"
  name             = "${local.resource_prefix}-codedeploy-app"

  tags = local.common_tags
}

# CodeDeploy Deployment Group for Win2016
resource "aws_codedeploy_deployment_group" "win2016" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2016-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "DeploymentTarget"
      type  = "KEY_AND_VALUE"
      value = "win2016"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}

# CodeDeploy Deployment Group for Win2019
resource "aws_codedeploy_deployment_group" "win2019" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2019-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "DeploymentTarget"
      type  = "KEY_AND_VALUE"
      value = "win2019"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}

# CodeDeploy Deployment Group for Win2022
resource "aws_codedeploy_deployment_group" "win2022" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2022-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "DeploymentTarget"
      type  = "KEY_AND_VALUE"
      value = "win2022"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = local.common_tags
}
