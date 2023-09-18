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
  destination                                          = "http_endpoint"
  buffering_interval                                   = 60
  http_endpoint_name                                   = var.http_endpoint_name
  http_endpoint_url                                    = var.http_endpoint_url
  http_endpoint_access_key                             = var.http_endpoint_access_key
  http_endpoint_retry_duration                         = 400
  http_endpoint_enable_request_configuration           = true
  http_endpoint_request_configuration_content_encoding = "GZIP"
  http_endpoint_request_configuration_common_attributes = [
    {
      name  = "testname"
      value = "testvalue"
    },
    {
      name  = "testname2"
      value = "testvalue2"
    }
  ]
  s3_backup_mode               = "All"
  s3_backup_prefix             = "backup/"
  s3_backup_bucket_arn         = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval = 100
  s3_backup_buffering_size     = 100
  s3_backup_compression        = "GZIP"
  s3_backup_enable_encryption  = true
  s3_backup_kms_key_arn        = aws_kms_key.this.arn
}
