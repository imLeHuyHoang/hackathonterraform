# Foundation Module - VPC Configuration (Default-like setup)

# Get current region's AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC with default-like configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-vpc"
  })
}

# Public Subnets (like default VPC - all public)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Auto-assign public IP like default VPC

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}

# Internet Gateway (essential for default-like behavior)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-igw"
  })
}

# Default Route Table (modify existing one like default VPC)
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-default-rt"
  })
}

# Default Security Group (modify existing one)
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  # Default inbound rules
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Default outbound rules (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-default-sg"
  })
}

# Additional Security Groups for specific services
resource "aws_security_group" "ec2_windows" {
  name        = "${local.resource_prefix}-ec2-windows-sg"
  description = "Security group for Windows EC2 instances"
  vpc_id      = aws_vpc.main.id

  # RDP access
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # WinRM (for CodeDeploy agent)
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # HTTP/HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-ec2-windows-sg"
  })
}

resource "aws_security_group" "lambda" {
  name        = "${local.resource_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  # Only outbound access needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.resource_prefix}-lambda-sg"
  })
}
