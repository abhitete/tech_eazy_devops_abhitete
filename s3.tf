# Generate a random suffix to make bucket name unique
resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

# Create the private S3 bucket with a unique name
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.s3_bucket_name}-${random_string.bucket_suffix.result}"
}

# S3 Bucket Lifecycle Rule to delete objects under /logs/ after 7 days
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "DeleteLogsAfter7Days"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 7
    }
  }
}
