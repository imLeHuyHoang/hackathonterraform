# Region & Project
project_name = "hackathon-vulnerability"
aws_region   = "ap-southeast-1"
environment  = "dev"

# VPC & Networking
vpc_cidr = "172.31.0.0/16"

public_subnets = [
  "172.31.0.0/20",
  "172.31.16.0/20",
  "172.31.32.0/20"
]

# EC2 Windows AMI IDs
win2016_ami_id = "ami-0696be2e6d8c0e89a"
win2019_ami_id = "ami-02f42821304e17830"
win2022_ami_id = "ami-04a9b7f1b67bebd6f"

# # EC2 SSH Key Pair Name
key_name = "my-hackathon-key"
deployment_packages_prefix = "deployment-packages/"

ec2_instance_type = "m7i.xlarge"