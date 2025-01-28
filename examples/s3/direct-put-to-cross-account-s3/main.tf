resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "this" {
  provider      = aws.account2
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.account2
  bucket   = aws_s3_bucket.this.id
  policy   = module.firehose.s3_cross_account_bucket_policy
}

module "firehose" {
  source                        = "../../../"
  name                          = "${var.name_prefix}-delivery-stream"
  destination                   = "s3"
  s3_bucket_arn                 = aws_s3_bucket.this.arn
  s3_cross_account              = true
  enable_sse                    = false
  enable_s3_backup              = true
  s3_backup_bucket_arn          = aws_s3_bucket.this.arn
  s3_backup_prefix              = "backup/"
  s3_backup_error_output_prefix = "error/"
  s3_backup_buffering_interval  = 100
  s3_backup_buffering_size      = 100
  s3_backup_compression         = "GZIP"
  s3_backup_enable_encryption   = false
  s3_backup_enable_log          = true
  create_application_role       = false
}
