terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.3"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev-netlumi-customer"
}

# Create unencrypted S3 bucket (security issue)
resource "aws_s3_bucket" "test_unencrypted" {
  bucket = "netlumi-test-baseline-unencrypted-${substr(uuid(), 0, 8)}"

  tags = {
    Name     = "netlumi-test-secure-baseline"
    Purpose  = "auto-pr-testing"
    HasIssue = "no-encryption"
  }
}

# Create IAM user without MFA (security issue)
resource "aws_iam_user" "test_user_no_mfa" {
  name = "netlumi-test-user-no-mfa"

  tags = {
    Name     = "netlumi-test-secure-baseline"
    Purpose  = "auto-pr-testing"
    HasIssue = "no-mfa-enforcement"
  }
}

# Attach admin policy to user (security issue - overly permissive)
resource "aws_iam_user_policy_attachment" "test_user_admin" {
  user       = aws_iam_user.test_user_no_mfa.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "bucket_id" {
  value = aws_s3_bucket.test_unencrypted.id
}

output "user_name" {
  value = aws_iam_user.test_user_no_mfa.name
}
