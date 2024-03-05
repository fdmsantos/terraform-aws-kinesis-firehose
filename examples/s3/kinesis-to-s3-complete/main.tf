resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_s3_bucket" "s3_backup" {
  bucket        = "${var.name_prefix}-backup-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_kinesis_stream" "this" {
  name             = "${var.name_prefix}-data-stream"
  shard_count      = 1
  retention_period = 48
  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

resource "aws_kms_key" "backup" {
  description             = "${var.name_prefix}-backup-kms-key"
  deletion_window_in_days = 7
}

module "firehose" {
  source                                        = "../../../"
  name                                          = "${var.name_prefix}-delivery-stream"
  buffering_size                                = 100
  buffering_interval                            = 100
  input_source                                  = "kinesis"
  kinesis_source_stream_arn                     = aws_kinesis_stream.this.arn
  destination                                   = "s3"
  s3_bucket_arn                                 = aws_s3_bucket.s3.arn
  s3_prefix                                     = "prod/user_id=!{partitionKeyFromQuery:user_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  s3_error_output_prefix                        = "error/"
  enable_s3_encryption                          = true
  s3_kms_key_arn                                = aws_kms_key.this.arn
  enable_destination_log                        = true
  enable_s3_backup                              = true
  s3_backup_bucket_arn                          = aws_s3_bucket.s3_backup.arn
  s3_backup_prefix                              = "backup/"
  s3_backup_error_output_prefix                 = "error/"
  s3_backup_buffering_interval                  = 100
  s3_backup_buffering_size                      = 100
  s3_backup_compression                         = "GZIP"
  s3_backup_enable_encryption                   = true
  s3_backup_kms_key_arn                         = aws_kms_key.backup.arn
  s3_backup_enable_log                          = true
  enable_data_format_conversion                 = true
  data_format_conversion_glue_database          = var.glue_database_name
  data_format_conversion_glue_table_name        = var.glue_table_name
  data_format_conversion_input_format           = "HIVE"
  data_format_conversion_output_format          = "ORC"
  enable_lambda_transform                       = true
  transform_lambda_arn                          = var.lambda_arn
  transform_lambda_buffer_size                  = 3
  transform_lambda_buffer_interval              = 60
  transform_lambda_number_retries               = 3
  enable_dynamic_partitioning                   = true
  dynamic_partitioning_retry_duration           = 350
  dynamic_partition_metadata_extractor_query    = "{user_id:.user_id}"
  append_delimiter_to_record                    = true
  dynamic_partition_enable_record_deaggregation = true
}
