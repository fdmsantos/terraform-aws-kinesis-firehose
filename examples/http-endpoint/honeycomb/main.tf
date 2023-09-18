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
  source                                               = "../../../"
  name                                                 = "${var.name_prefix}-delivery-stream"
  destination                                          = "honeycomb"
  buffering_interval                                   = 60
  honeycomb_api_host                                   = "https://api.honeycomb.io"
  honeycomb_dataset_name                               = var.honeycomb_dataset_name
  http_endpoint_access_key                             = var.honeycomb_api_key
  http_endpoint_retry_duration                         = 60
  http_endpoint_enable_request_configuration           = true
  http_endpoint_request_configuration_content_encoding = "GZIP"
  s3_backup_mode                                       = "All"
  s3_backup_prefix                                     = "backup/"
  s3_backup_bucket_arn                                 = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval                         = 100
  s3_backup_buffering_size                             = 100
  s3_backup_compression                                = "GZIP"
  s3_backup_enable_encryption                          = true
  s3_backup_kms_key_arn                                = aws_kms_key.this.arn
}
