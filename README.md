# AWS Kinesis Firehose Terraform module

Terraform module, which creates a Kinesis Firehose Stream and others resources like Cloudwatch and IAM Role  that integrate with Kinesis Firehose.

## Features

- Kinesis Data Stream or Direct Put as source.
- S3 Destination.
- Data Transformation With Lambda
- Data Format Conversion
- Dynamic Partition
- S3 Backup
- Logging and Encryption

## Usage

### Kinesis Firehose with Kinesis Data Stream as Source

```hcl
module "firehose" {
  source                    = "."
  name                      = "firehose-delivery-stream"
  enable_kinesis_source     = true
  kinesis_source_stream_arn = "<kinesis_stream_arn>"
  destination               = "extended_s3"
  destination_s3_bucket_arn = "<bucket_arn>"
}

```

### Kinesis Firehose with Direct Put as Source

```hcl
module "firehose" {
  source                        = "."
  name                          = "firehose-delivery-stream"
  destination                   = "extended_s3"
  destination_s3_bucket_arn     = "<bucket_arn>"
}

```

### Lambda Transformation

```hcl
module "firehose" {
  source                                        = "."
  name                                          = "firehose-delivery-stream"
  enable_kinesis_source                         = true
  kinesis_source_stream_arn                     = "<kinesis_stream_arn>"
  destination                                   = "extended_s3"
  destination_s3_bucket_arn                     = "<bucket_arn>"
  transform_lambda_arn                          = "<lambda_arn>"
  transform_lambda_buffer_size                  = 3
  transform_lambda_buffer_interval              = 60
  transform_lambda_number_retries               = 3
}

```

### Data Format Conversion

```hcl
module "firehose" {
  source                                        = "."
  name                                          = "firehose-delivery-stream"
  enable_kinesis_source                         = true
  kinesis_source_stream_arn                     = "<kinesis_stream_arn>"
  destination                                   = "extended_s3"
  destination_s3_bucket_arn                     = "<bucket_arn>"
  enable_data_format_conversion                 = true
  data_format_conversion_glue_database          = "<glue_database_name>"
  data_format_conversion_glue_table_name        = "<glue_table_name>"
  data_format_conversion_deserializer           = "HIVE"
  data_format_conversion_serializer             = "ORC"
}

```

### Dynamic Partition

```hcl
module "firehose" {
  source                                        = "."
  name                                          = "firehose-delivery-stream"
  enable_kinesis_source                         = true
  kinesis_source_stream_arn                     = "<kinesis_stream_arn>"
  destination                                   = "extended_s3"
  destination_s3_bucket_arn                     = "<bucket_arn>"
  s3_prefix                                     = "prod/user_id=!{partitionKeyFromQuery:user_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  enable_dynamic_partitioning                   = true
  dynamic_partitioning_retry_duration           = 350
  dynamic_partition_metadata_extractor_query    = "{user_id:.user_id}"
  dynamic_partition_append_delimiter_to_record  = true
  dynamic_partition_enable_record_deaggregation = true
}

```

## License

Apache 2 Licensed. See [LICENSE](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/LICENSE) for full details.