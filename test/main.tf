terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.73, < 7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Test that our fixed module can be initialized without warnings
module "test_firehose" {
  source = "./.."

  name = "test-firehose"
  
  # Minimal required configuration
  destination = "s3"
  s3_bucket_arn = "arn:aws:s3:::test-bucket"
  
  # Disable features that require additional resources
  enable_data_format_conversion = false
  enable_destination_log = false
  s3_backup_enable_log = false
  enable_s3_encryption = false
  s3_backup_enable_encryption = false
}
