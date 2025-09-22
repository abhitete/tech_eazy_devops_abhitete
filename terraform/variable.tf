variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
  default     = "techeazy"   # your key pair without .pem
}

variable "stage" {
  description = "Deployment stage (dev, prod, test)"
  type        = string
  default     = "dev"
}
