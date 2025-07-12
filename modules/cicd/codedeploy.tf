resource "aws_codedeploy_app" "windows_patch_app" {
  name              = "${local.resource_prefix}-codedeploy-app"
  compute_platform  = "Server"

  tags = local.common_tags
}

# Deployment Group - Win2016
resource "aws_codedeploy_deployment_group" "win2016" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2016-group"
  service_role_arn      = var.codedeploy_service_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.environment}-win2016"
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  tags = local.common_tags
}

# Deployment Group - Win2019
resource "aws_codedeploy_deployment_group" "win2019" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2019-group"
  service_role_arn      = var.codedeploy_service_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.environment}-win2019"
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  tags = local.common_tags
}

# Deployment Group - Win2022
resource "aws_codedeploy_deployment_group" "win2022" {
  app_name              = aws_codedeploy_app.windows_patch_app.name
  deployment_group_name = "${local.resource_prefix}-win2022-group"
  service_role_arn      = var.codedeploy_service_role_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.environment}-win2022"
    }
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  tags = local.common_tags
}
