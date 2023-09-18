resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.name_prefix}-backup-role"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "firehose" {
  source                             = "../../../"
  name                               = "${var.name_prefix}-delivery-stream"
  destination                        = "s3"
  s3_bucket_arn                      = aws_s3_bucket.s3.arn
  enable_sse                         = true
  sse_kms_key_type                   = "CUSTOMER_MANAGED_CMK"
  sse_kms_key_arn                    = aws_kms_key.this.arn
  enable_s3_backup                   = true
  s3_backup_bucket_arn               = aws_s3_bucket.s3.arn
  s3_backup_prefix                   = "backup/"
  s3_backup_error_output_prefix      = "error/"
  s3_backup_buffering_interval       = 100
  s3_backup_buffering_size           = 100
  s3_backup_compression              = "GZIP"
  s3_backup_use_existing_role        = false
  s3_backup_role_arn                 = aws_iam_role.this.arn
  s3_backup_enable_encryption        = true
  s3_backup_kms_key_arn              = aws_kms_key.this.arn
  s3_backup_enable_log               = true
  create_application_role            = true
  create_application_role_policy     = true
  application_role_service_principal = "ec2.amazonaws.com"
}
