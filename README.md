# DevOps Assignment 2 - Terraform & AWS Automation

## Description
This assignment extends the previous automation to include:

1. Creation of two IAM roles:
   - **Read-only role** for S3 access.
   - **Full-access role** to create buckets and upload files (no read/download permissions).

2. Attaching the full-access role to an EC2 instance using an **Instance Profile**.

3. Creating a private S3 bucket (configurable name).

4. Uploading EC2 and application logs to the S3 bucket after instance shutdown for archival.

5. Adding an S3 **lifecycle rule** to delete logs under `/logs/` after 7 days.

6. Verifying S3 list operations using the read-only role.

## Files
- `main.tf` - Terraform configuration for VPC, subnet, EC2, IAM roles, and security group.
- `variable.tf` - Variables used in Terraform.
- `output.tf` - Outputs, including EC2 public IP and bucket name.
- `s3.tf` - Terraform configuration for S3 bucket and lifecycle rules.
- `upload_logs.sh` - Bash script to upload logs from EC2 to S3.

## Usage
1. Initialize Terraform:
```bash
terraform init
