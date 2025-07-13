output "pipelines" {
  value = {
    win2016 = aws_codepipeline.win2016.name
    win2019 = aws_codepipeline.win2019.name
    win2022 = aws_codepipeline.win2022.name
  }
}

output "codedeploy_application_name" {
  value = aws_codedeploy_app.windows_patch_app.name
}

# CloudWatch Log Groups outputs
output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for CodeDeploy monitoring"
  value = {
    codedeploy_agent_log      = aws_cloudwatch_log_group.codedeploy_agent_log.name
    codedeploy_deployment_log = aws_cloudwatch_log_group.codedeploy_deployment_log.name
    codedeploy_scripts_log    = aws_cloudwatch_log_group.codedeploy_scripts_log.name
    ec2_userdata_log          = aws_cloudwatch_log_group.ec2_userdata_log.name
    windows_system_log        = aws_cloudwatch_log_group.windows_system_log.name
    windows_application_log   = aws_cloudwatch_log_group.windows_application_log.name
  }
}

# CloudWatch Log Group ARNs for reference
output "cloudwatch_log_group_arns" {
  description = "CloudWatch log group ARNs"
  value = {
    codedeploy_agent_log      = aws_cloudwatch_log_group.codedeploy_agent_log.arn
    codedeploy_deployment_log = aws_cloudwatch_log_group.codedeploy_deployment_log.arn
    codedeploy_scripts_log    = aws_cloudwatch_log_group.codedeploy_scripts_log.arn
    ec2_userdata_log          = aws_cloudwatch_log_group.ec2_userdata_log.arn
  }
}
