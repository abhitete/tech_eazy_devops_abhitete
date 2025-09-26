variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of your EC2 key pair"
  type        = string
}

variable "stage" {
  description = "Deployment stage (dev, prod)"
  type        = string
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "Private S3 bucket name for logs"
  type        = string
}
