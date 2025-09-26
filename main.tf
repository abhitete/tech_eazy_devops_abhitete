# --------------------------
# Provider
# --------------------------
provider "aws" {
  region = var.aws_region
}

# --------------------------
# Get latest Ubuntu 22.04 LTS AMI
# --------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --------------------------
# VPC, Subnet, IGW, Route Table
# --------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------------
# Security Group
# --------------------------
resource "aws_security_group" "instance_sg" {
  name        = "Allow_App"
  description = "Allow SSH and App traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------
# IAM Roles
# --------------------------
# Role 1.a - ReadOnly S3
resource "aws_iam_role" "s3_read_role" {
  name = "S3ReadOnlyRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "s3_read_attach" {
  name       = "attach-read-only-policy"
  roles      = [aws_iam_role.s3_read_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Role 1.b - S3 Full Access (create/upload, no read/download)
resource "aws_iam_role" "s3_full_role" {
  name = "S3FullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_full_policy" {
  name        = "S3FullAccessPolicy"
  description = "Create bucket, upload files, no read/download"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:PutBucket*",
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_full_attach" {
  name       = "attach-full-access-policy"
  roles      = [aws_iam_role.s3_full_role.name]
  policy_arn = aws_iam_policy.s3_full_policy.arn
}

# Instance Profile to attach Role 1.b to EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "JavaAppEC2Profile"
  role = aws_iam_role.s3_full_role.name
}

# --------------------------
# EC2 Instance
# --------------------------
resource "aws_instance" "JavaApp_EC2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = templatefile("${path.module}/../scripts/user_data.sh", {
    stage = var.stage
  })

  tags = {
    Name = "JavaApp_EC2"
  }
}

# --------------------------
# Private S3 Bucket for Logs
# --------------------------
resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "LogsBucket"
  }
}

# Block all public access (make bucket private)
resource "aws_s3_bucket_public_access_block" "logs_bucket_block" {
  bucket                  = aws_s3_bucket.logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
