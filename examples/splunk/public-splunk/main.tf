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

module "firehose" {
  source                            = "../../../"
  name                              = "${var.name_prefix}-delivery-stream"
  destination                       = "splunk"
  buffering_interval                = 60
  splunk_hec_endpoint               = var.splunk_hec_endpoint
  splunk_hec_endpoint_type          = var.splunk_hec_endpoint_type
  splunk_hec_token                  = var.splunk_hec_token
  splunk_hec_acknowledgment_timeout = 450
  splunk_retry_duration             = 450
  s3_backup_mode                    = "All"
  s3_backup_prefix                  = "backup/"
  s3_backup_bucket_arn              = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval      = 100
  s3_backup_buffering_size          = 100
  s3_backup_compression             = "GZIP"
  s3_backup_enable_encryption       = true
  s3_backup_kms_key_arn             = aws_kms_key.this.arn
}
