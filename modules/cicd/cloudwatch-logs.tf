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

# CodeDeploy Scripts Log Group (cho lifecycle hooks)
resource "aws_cloudwatch_log_group" "codedeploy_scripts_log" {
  name              = "/aws/codedeploy/scripts"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-codedeploy-scripts-logs"
    Purpose = "CodeDeploy lifecycle scripts logs"
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

# Windows Event Logs
resource "aws_cloudwatch_log_group" "windows_system_log" {
  name              = "/aws/ec2/windows/system"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-windows-system-logs"
    Purpose = "Windows System Event logs"
  })
}

# Windows Application Logs
resource "aws_cloudwatch_log_group" "windows_application_log" {
  name              = "/aws/ec2/windows/application"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Name    = "${local.resource_prefix}-windows-application-logs"
    Purpose = "Windows Application Event logs"
  })
}
