# Pipeline - Win2016
resource "aws_codepipeline" "win2016" {
  name     = "${local.resource_prefix}-win2016-pipeline"
  role_arn = var.codepipeline_service_role_arn

  artifact_store {
    location = var.artifacts_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "S3Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = var.main_bucket_name
        S3ObjectKey = "${var.deployment_packages_prefix}windows-server-2016/latest-deployment.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "DeployToEC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.windows_patch_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.win2016.deployment_group_name
      }
    }
  }

  tags = local.common_tags
}

# Pipeline - Win2019
resource "aws_codepipeline" "win2019" {
  name     = "${local.resource_prefix}-win2019-pipeline"
  role_arn = var.codepipeline_service_role_arn

  artifact_store {
    location = var.artifacts_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "S3Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = var.main_bucket_name
        S3ObjectKey = "${var.deployment_packages_prefix}windows-server-2019/latest-deployment.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "DeployToEC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.windows_patch_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.win2019.deployment_group_name
      }
    }
  }

  tags = local.common_tags
}

# Pipeline - Win2022
resource "aws_codepipeline" "win2022" {
  name     = "${local.resource_prefix}-win2022-pipeline"
  role_arn = var.codepipeline_service_role_arn

  artifact_store {
    location = var.artifacts_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "S3Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = var.main_bucket_name
        S3ObjectKey = "${var.deployment_packages_prefix}windows-server-2022/latest-deployment.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "DeployToEC2"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.windows_patch_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.win2022.deployment_group_name
      }
    }
  }

  tags = local.common_tags
}
