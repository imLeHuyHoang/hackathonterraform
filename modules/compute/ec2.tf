# =============================================================================
# Tạo các máy chủ Windows Server (2016, 2019, 2022) cho việc patching CVE
# Mỗi server sẽ được cài sẵn CodeDeploy Agent để nhận deployment từ CodePipeline
# =============================================================================
resource "aws_instance" "win2016" {

  ami                    = var.win2016_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name #


  associate_public_ip_address = true
  disable_api_termination     = false
  disable_api_stop            = false
  monitoring                  = false

  user_data_base64 = base64encode(templatefile("${path.module}/userdata/install-codedeploy-agent.ps1", {
    region          = var.aws_region
    windows_version = "2016"
  }))

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = false

    # 🏷️ Tags cho ổ cứng
    tags = merge(local.common_tags, {
      Name = "${var.environment}-win2016-root"
    })
  }


  tags = merge(local.common_tags, {
    Name             = "${var.environment}-win2016"
    Patch            = "Windows Server 2016"
    Environment      = var.environment
    WindowsVersion   = "2016"
    DeploymentTarget = "win2016"
  })
}

resource "aws_instance" "win2019" {
  ami                    = var.win2019_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true
  disable_api_termination     = false
  disable_api_stop            = false
  monitoring                  = false

  user_data_base64 = base64encode(templatefile("${path.module}/userdata/install-codedeploy-agent.ps1", {
    region          = var.aws_region
    windows_version = "2019"
  }))

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = false

    tags = merge(local.common_tags, {
      Name = "${var.environment}-win2019-root"
    })
  }

  tags = merge(local.common_tags, {
    Name             = "${var.environment}-win2019"
    Patch            = "Windows Server 2019"
    Environment      = var.environment
    WindowsVersion   = "2019"
    DeploymentTarget = "win2019"
  })
}

resource "aws_instance" "win2022" {
  ami                    = var.win2022_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true
  disable_api_termination     = false
  disable_api_stop            = false
  monitoring                  = false

  user_data_base64 = base64encode(templatefile("${path.module}/userdata/install-codedeploy-agent.ps1", {
    region          = var.aws_region
    windows_version = "2022"
  }))

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = false

    tags = merge(local.common_tags, {
      Name = "${var.environment}-win2022-root"
    })
  }

  tags = merge(local.common_tags, {
    Name             = "${var.environment}-win2022"
    Patch            = "Windows Server 2022"
    Environment      = var.environment
    WindowsVersion   = "2022"
    DeploymentTarget = "win2022" # 🎯 CodeDeploy targeting
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = var.ec2_instance_role_name
}
