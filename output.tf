output "instance_public_ip_javaapp" {
  description = "Public IP of the JavaApp EC2 instance"
  value       = aws_instance.JavaApp_EC2.public_ip
}
output "s3_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = aws_s3_bucket.logs_bucket.id
}
