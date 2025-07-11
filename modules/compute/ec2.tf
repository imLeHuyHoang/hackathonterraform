# =======================
# EC2 Instances Windows
# =======================

# Windows Server 2016
resource "aws_instance" "win2016" {
  ami                    = var.win2016_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = merge(local.common_tags, {
    Name  = "${var.environment}-win2016"
    Patch = "Windows Server 2016"
  })
}

# Windows Server 2019
resource "aws_instance" "win2019" {
  ami                    = var.win2019_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = merge(local.common_tags, {
    Name  = "${var.environment}-win2019"
    Patch = "Windows Server 2019"
  })
}

# Windows Server 2022
resource "aws_instance" "win2022" {
  ami                    = var.win2022_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = merge(local.common_tags, {
    Name  = "${var.environment}-win2022"
    Patch = "Windows Server 2022"
  })
}

# EBS Volumes (nếu muốn gắn thêm)
# resource "aws_ebs_volume" "win2016" {
#   availability_zone = aws_instance.win2016.availability_zone
#   size              = 30
#   type              = "gp3"

#   tags = merge(var.common_tags, {
#     Name = "${var.environment}-win2016-ebs"
#   })
# }

# resource "aws_volume_attachment" "win2016_attach" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.win2016.id
#   instance_id = aws_instance.win2016.id
# }

# IAM Instance Profile (liên kết với role đã tạo từ foundation)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-instance-profile"
  role = var.ec2_instance_role_name
}
