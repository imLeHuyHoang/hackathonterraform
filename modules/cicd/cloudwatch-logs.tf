# CloudWatch Log Groups for CodeDeploy Agent Logs

# CodeDeploy Agent Main Log Group
resource "aws_cloudwatch_log_group" "codedeploy_agent_log" {
  name              = "/aws/codedeploy/agent"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-codedeploy-agent-logs"
    Purpose = "CodeDeploy agent main logs"
  })
}

# CodeDeploy Deployment Log Group
resource "aws_cloudwatch_log_group" "codedeploy_deployment_log" {
  name              = "/aws/codedeploy/deployments"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-codedeploy-deployment-logs"
    Purpose = "CodeDeploy deployment logs"
  })
}

# CodeDeploy Agent Updater Log Group
resource "aws_cloudwatch_log_group" "codedeploy_updater_log" {
  name              = "/aws/codedeploy/updater"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-codedeploy-updater-logs"
    Purpose = "CodeDeploy agent updater logs"
  })
}

# User Data Execution Log Group
resource "aws_cloudwatch_log_group" "ec2_userdata_log" {
  name              = "/aws/ec2/userdata"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-ec2-userdata-logs"
    Purpose = "EC2 user data execution logs"
  })
}
