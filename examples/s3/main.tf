provider "aws" {
  region                      = local.region
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  region = "eu-west-1"
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "s3-bucket-${random_pet.this.id}"
  force_destroy = true
}

module "firehose" {
  source                                           = "../../"
  name                                             = "firehose-s3"
  destination                                      = "extended_s3"
  buffer_size                                      = 64
  s3_bucket_arn                                    = aws_s3_bucket.s3.arn
  s3_prefix                                        = "data/customer_id=!{partitionKeyFromQuery:customer_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  s3_error_output_prefix                           = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
  enable_dynamic_partitioning                      = true
  dynamic_partitioning_retry_duration              = 350
  dynamic_partition_metadata_extractor_query       = "{customer_id:.customer_id}"
  dynamic_partition_append_delimiter_to_record     = true
  dynamic_partition_enable_record_deaggregation    = true
  dynamic_partition_record_deaggregation_type      = "DELIMITED"
  dynamic_partition_record_deaggregation_delimiter = "test"
  transform_lambda_arn                             = var.lambda_arn
  transform_lambda_buffer_size                     = 3
  transform_lambda_buffer_interval                 = 60
  transform_lambda_number_retries                  = 3
  enable_data_format_conversion                    = true
  data_format_conversion_glue_database             = var.glue_database
  #  data_format_conversion_glue_role_arn = ""
  data_format_conversion_glue_table_name = var.glue_table
  #  data_format_conversion_openX_case_insensitive = false
  #  data_format_conversion_openX_convert_dots_to_underscores = true
  #  data_format_conversion_openX_column_to_json_key_mappings = { ts = "timestamp" }
  data_format_conversion_deserializer = "HIVE"
  #  data_format_conversion_hive_timestamps =
  #  data_format_conversion_serializer = "ORC"
  #  data_format_conversion_orc_compression = "ZLIB"
  #  data_format_conversion_orc_dict_key_threshold = 0.5
  s3_backup_enable_log = true
  enable_s3_backup = true
  s3_backup_bucket_arn = aws_s3_bucket.s3.arn
  s3_backup_kms_key_arn = var.s3_backup_kms_key
  sse_enabled = false
  ss3_key_type = "CUSTOMER_MANAGED_CMK"
  sse_key_arn = var.s3_backup_kms_key
#  kinesis_source_stream_arn = "arn:aws:kinesis:eu-west-1:661516917150:stream/test"
  enable_destination_log = true
  kms_key_arn = var.s3_backup_kms_key
#  compression_format = "GZIP"
}