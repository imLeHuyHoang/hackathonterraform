# Generate SSH key pair using Terraform
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pair using generated public key
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = merge(local.common_tags, {
    Name        = "${local.resource_prefix}-keypair"
    WindowsAuth = "RDP Access"
    Purpose     = "Windows Server authentication"
  })
}

# Save private key to local file (for RDP password decryption)
resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "${path.root}/windows-keypair.pem"
  
  # Set proper permissions (read-only for owner)
  file_permission = "0400"
}

# Save public key to local file (for reference)
resource "local_file" "public_key" {
  content  = tls_private_key.ec2_key.public_key_openssh
  filename = "${path.root}/windows-keypair.pub"
  
  file_permission = "0644"
}

# Save private key in OpenSSH format (for SSH if needed)
resource "local_file" "private_key_openssh" {
  content  = tls_private_key.ec2_key.private_key_openssh
  filename = "${path.root}/windows-keypair-openssh.key"
  
  file_permission = "0400"
}