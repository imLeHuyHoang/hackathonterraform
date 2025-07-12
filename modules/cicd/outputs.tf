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
