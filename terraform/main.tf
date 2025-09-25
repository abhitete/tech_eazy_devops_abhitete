# === S3 write-only role (create bucket & put object, deny read/list) ===
resource "aws_iam_role" "s3_write_role" {
  name = "s3-write-only-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Managed custom policy allowing CreateBucket and PutObject (deny read)
resource "aws_iam_policy" "s3_write_policy" {
  name        = "s3-write-only-policy"
  description = "Allow CreateBucket and PutObject, explicitly deny read/list"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_write_policy" {
  role       = aws_iam_role.s3_write_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

# Instance profile used by EC2
resource "aws_iam_instance_profile" "s3_write_instance_profile" {
  name = "s3-write-instance-profile"
  role = aws_iam_role.s3_write_role.name
}

# === Attach instance profile to your aws_instance ===
# In your existing aws_instance resource add this attribute:
#
#   iam_instance_profile = aws_iam_instance_profile.s3_write_instance_profile.name
#
# Example (snippet):
#
# resource "aws_instance" "JavaApp_EC2" {
#   ...
#   key_name             = var.key_name
#   iam_instance_profile = aws_iam_instance_profile.s3_write_instance_profile.name
#   ...
# }
