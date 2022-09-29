data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  firehose_role_arn                   = var.create_role ? aws_iam_role.firehose[0].arn : var.firehose_role
  cw_log_group_name                   = "/aws/kinesisfirehose/${var.name}"
  cw_log_delivery_stream_name         = "DestinationDelivery"
  cw_log_backup_stream_name           = "BackupDelivery"
  destinations = {
    extended_s3 : "extended_s3",
    redshift : "redshift",
    elasticsearch : "elasticsearch",
    splunk : "splunk",
    http_endpoint : "http_endpoint"
  }
  destination    = local.destinations[var.destination]
  s3_destination = local.destination == "extended_s3" ? true : false

  # Data Transformation
  enable_processing = var.enable_lambda_transform || var.enable_dynamic_partitioning
  lambda_processor = var.enable_lambda_transform ? {
    type = "Lambda"
    parameters = [
      {
        name  = "LambdaArn"
        value = var.transform_lambda_arn
      },
      {
        name  = "BufferSizeInMBs"
        value = var.transform_lambda_buffer_size
      },
      {
        name  = "BufferIntervalInSeconds"
        value = var.transform_lambda_buffer_interval
      },
      {
        name  = "NumberOfRetries"
        value = var.transform_lambda_number_retries
      },
    ]
  } : null
  metadata_extractor_processor = var.enable_dynamic_partitioning && var.dynamic_partition_metadata_extractor_query != null ? {
    type = "MetadataExtraction"
    parameters = [
      {
        name  = "JsonParsingEngine"
        value = "JQ-1.6"
      },
      {
        name  = "MetadataExtractionQuery"
        value = var.dynamic_partition_metadata_extractor_query
      },
    ]
  } : null
  append_delimiter_processor = var.enable_dynamic_partitioning && var.dynamic_partition_append_delimiter_to_record ? {
    type       = "AppendDelimiterToRecord"
    parameters = []
  } : null
  record_deaggregation_processor_json = {
    type = "RecordDeAggregation"
    parameters = [
      {
        name  = "SubRecordType"
        value = var.dynamic_partition_record_deaggregation_type
      },
    ]
  }
  record_deaggregation_processor_delimiter = {
    type = "RecordDeAggregation"
    parameters = [
      {
        name  = "SubRecordType"
        value = var.dynamic_partition_record_deaggregation_type
      },
      {
        name  = "Delimiter"
        value = var.dynamic_partition_record_deaggregation_delimiter
      },
    ]
  }
  record_deaggregation_processor = (var.enable_dynamic_partitioning && var.dynamic_partition_enable_record_deaggregation ?
    (var.dynamic_partition_record_deaggregation_type == "JSON" ? local.record_deaggregation_processor_json : local.record_deaggregation_processor_delimiter)
  : null)
  processors = [for each in [
    local.lambda_processor,
    local.metadata_extractor_processor,
    local.append_delimiter_processor,
    local.record_deaggregation_processor
  ] : each if local.enable_processing && each != null]

  # Data Format conversion
  data_format_conversion_glue_catalog_id = (var.enable_data_format_conversion ?
    (var.data_format_conversion_glue_catalog_id != null ? var.data_format_conversion_glue_catalog_id : data.aws_caller_identity.current.account_id)
  : null)

  data_format_conversion_glue_region = (var.enable_data_format_conversion ?
    (var.data_format_conversion_glue_region != null ? var.data_format_conversion_glue_region : data.aws_region.current.name)
  : null)

  data_format_conversion_glue_role = (var.enable_data_format_conversion ? (
    var.data_format_conversion_glue_use_existing_role ? local.firehose_role_arn : var.data_format_conversion_glue_role_arn
  ) : null)

  # S3 Backup
  use_backup_vars_in_s3_configuration = contains(["elasticsearch", "splunk", "http_endpoint"], local.destination) ? true : false
  s3_backup        = var.enable_s3_backup ? "Enabled" : "Disabled"
  enable_s3_backup = var.enable_s3_backup || local.use_backup_vars_in_s3_configuration
  s3_backup_role_arn = (local.enable_s3_backup ? (
    var.s3_backup_use_existing_role ? local.firehose_role_arn : var.s3_backup_role_arn
  ) : null)
  s3_backup_cw_log_group_name  = var.create_destination_cw_log_group ? local.cw_log_group_name : var.s3_backup_log_group_name
  s3_backup_cw_log_stream_name = var.create_destination_cw_log_group ? local.cw_log_backup_stream_name : var.s3_backup_log_stream_name
  backup_modes = {
    elasticsearch : {
      FailedOnly : "FailedDocumentsOnly",
      All : "AllDocuments"
    }
    splunk : {
      FailedOnly : "FailedEventsOnly",
      All : "AllEvents"
    }
    http_endpoint : {
      FailedOnly : "FailedDataOnly",
      All : "AllData"
    }
  }
  s3_backup_mode = local.use_backup_vars_in_s3_configuration ? local.backup_modes[local.destination][var.s3_backup_mode] : null

  # Kinesis source Stream
  kinesis_source_stream_role = (var.enable_kinesis_source ? (
    var.kinesis_source_use_existing_role ? local.firehose_role_arn : var.kinesis_source_role_arn
  ) : null)

  # Destination Log
  destination_cw_log_group_name  = var.create_destination_cw_log_group ? local.cw_log_group_name : var.destination_log_group_name
  destination_cw_log_stream_name = var.create_destination_cw_log_group ? local.cw_log_delivery_stream_name : var.destination_log_stream_name

  # Cloudwatch
  create_destination_logs = var.enable_destination_log && var.create_destination_cw_log_group
  create_backup_logs      = var.enable_s3_backup && var.s3_backup_enable_log && var.s3_backup_create_cw_log_group

  # Elasticsearch Destination
  #  elasticsearch_in_vpc = var.elasticsearch_vpc_subnet_ids != null || var.elasticsearch_vpc_security_group_ids != null ? true : false
  #  elasticsearch_vpc_role_arn = (var.destination == "elasticsearch" ? (
  #    var.elasticsearch_vpc_use_existing_role ? local.firehose_role_arn : var.elasticsearch_vpc_role_arn
  #  ) : null)
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.name
  destination = local.destination

  dynamic "kinesis_source_configuration" {
    for_each = var.enable_kinesis_source ? [1] : []
    content {
      kinesis_stream_arn = var.kinesis_source_stream_arn
      role_arn           = local.kinesis_source_stream_role
    }
  }

  dynamic "server_side_encryption" {
    for_each = !var.enable_kinesis_source && var.enable_sse ? [1] : []
    content {
      enabled  = var.enable_sse
      key_arn  = var.sse_kms_key_arn
      key_type = var.sse_kms_key_type
    }
  }

  dynamic "extended_s3_configuration" {
    for_each = local.s3_destination ? [1] : []
    content {
      role_arn            = local.firehose_role_arn
      bucket_arn          = var.s3_bucket_arn
      prefix              = var.s3_prefix
      error_output_prefix = var.s3_error_output_prefix
      buffer_size         = var.buffer_size
      buffer_interval     = var.buffer_interval
      s3_backup_mode      = local.s3_backup
      kms_key_arn         = var.enable_s3_encryption ? var.s3_kms_key_arn : null
      compression_format  = var.s3_compression_format

      dynamic "dynamic_partitioning_configuration" {
        for_each = var.enable_dynamic_partitioning ? [1] : []
        content {
          enabled        = var.enable_dynamic_partitioning
          retry_duration = var.dynamic_partitioning_retry_duration
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }

      dynamic "data_format_conversion_configuration" {
        for_each = var.enable_data_format_conversion ? [1] : []
        content {
          input_format_configuration {
            deserializer {
              dynamic "open_x_json_ser_de" {
                for_each = var.data_format_conversion_input_format == "OpenX" ? [1] : []
                content {
                  case_insensitive                         = var.data_format_conversion_openx_case_insensitive
                  convert_dots_in_json_keys_to_underscores = var.data_format_conversion_openx_convert_dots_to_underscores
                  column_to_json_key_mappings              = var.data_format_conversion_openx_column_to_json_key_mappings
                }
              }
              dynamic "hive_json_ser_de" {
                for_each = var.data_format_conversion_input_format == "HIVE" ? [1] : []
                content {
                  timestamp_formats = var.data_format_conversion_hive_timestamps
                }
              }
            }
          }

          output_format_configuration {
            serializer {
              dynamic "parquet_ser_de" {
                for_each = var.data_format_conversion_output_format == "PARQUET" ? [1] : []
                content {
                  block_size_bytes              = var.data_format_conversion_block_size
                  compression                   = var.data_format_conversion_parquet_compression
                  enable_dictionary_compression = var.data_format_conversion_parquet_dict_compression
                  max_padding_bytes             = var.data_format_conversion_parquet_max_padding
                  page_size_bytes               = var.data_format_conversion_parquet_page_size
                  writer_version                = var.data_format_conversion_parquet_writer_version
                }
              }
              dynamic "orc_ser_de" {
                for_each = var.data_format_conversion_output_format == "ORC" ? [1] : []
                content {
                  block_size_bytes                        = var.data_format_conversion_block_size
                  compression                             = var.data_format_conversion_orc_compression
                  format_version                          = var.data_format_conversion_orc_format_version
                  enable_padding                          = var.data_format_conversion_orc_enable_padding
                  padding_tolerance                       = var.data_format_conversion_orc_padding_tolerance
                  dictionary_key_threshold                = var.data_format_conversion_orc_dict_key_threshold
                  bloom_filter_columns                    = var.data_format_conversion_orc_bloom_filter_columns
                  bloom_filter_false_positive_probability = var.data_format_conversion_orc_bloom_filter_false_positive_probability
                  row_index_stride                        = var.data_format_conversion_orc_row_index_stripe
                  stripe_size_bytes                       = var.data_format_conversion_orc_stripe_size
                }
              }
            }
          }

          schema_configuration {
            database_name = var.data_format_conversion_glue_database
            role_arn      = local.data_format_conversion_glue_role
            table_name    = var.data_format_conversion_glue_table_name
            catalog_id    = local.data_format_conversion_glue_catalog_id
            region        = local.data_format_conversion_glue_region
            version_id    = var.data_format_conversion_glue_version_id
          }
        }
      }

      dynamic "s3_backup_configuration" {
        for_each = var.enable_s3_backup ? [1] : []
        content {
          bucket_arn          = var.s3_backup_bucket_arn
          role_arn            = local.s3_backup_role_arn
          prefix              = var.s3_backup_prefix
          buffer_size         = var.s3_backup_buffer_size
          buffer_interval     = var.s3_backup_buffer_interval
          compression_format  = var.s3_backup_compression
          error_output_prefix = var.s3_backup_error_output_prefix
          kms_key_arn         = var.s3_backup_enable_encryption ? var.s3_backup_kms_key_arn : null
          cloudwatch_logging_options {
            enabled         = var.s3_backup_enable_log
            log_group_name  = local.s3_backup_cw_log_group_name
            log_stream_name = local.s3_backup_cw_log_stream_name
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = var.enable_destination_log ? [1] : []
        content {
          enabled         = var.enable_destination_log
          log_group_name  = local.destination_cw_log_group_name
          log_stream_name = local.destination_cw_log_stream_name
        }
      }
    }
  }

  dynamic "s3_configuration" {
    for_each = !local.s3_destination ? [1] : []
    content {
      role_arn            = !local.use_backup_vars_in_s3_configuration ? local.firehose_role_arn : local.s3_backup_role_arn
      bucket_arn          = !local.use_backup_vars_in_s3_configuration ? var.s3_bucket_arn : var.s3_backup_bucket_arn
      buffer_size         = !local.use_backup_vars_in_s3_configuration ? var.buffer_size : var.s3_backup_buffer_size
      buffer_interval     = !local.use_backup_vars_in_s3_configuration ? var.buffer_interval : var.s3_backup_buffer_interval
      compression_format  = !local.use_backup_vars_in_s3_configuration ? var.s3_compression_format : var.s3_backup_compression
      prefix              = !local.use_backup_vars_in_s3_configuration ? var.s3_prefix : var.s3_backup_prefix
      error_output_prefix = !local.use_backup_vars_in_s3_configuration ? var.s3_error_output_prefix : var.s3_backup_error_output_prefix
      kms_key_arn         = (!local.use_backup_vars_in_s3_configuration && var.enable_s3_encryption ? var.s3_kms_key_arn : (local.use_backup_vars_in_s3_configuration && var.s3_backup_enable_encryption ? var.s3_backup_kms_key_arn : null))
    }
  }

  dynamic "redshift_configuration" {
    for_each = local.destination == "redshift" ? [1] : []
    content {
      role_arn           = local.firehose_role_arn
      cluster_jdbcurl    = "jdbc:redshift://${var.redshift_cluster_endpoint}/${var.redshift_database_name}"
      username           = var.redshift_username
      password           = var.redshift_password
      data_table_name    = var.redshift_table_name
      copy_options       = var.redshift_copy_options
      data_table_columns = var.redshift_data_table_columns
      s3_backup_mode     = local.s3_backup
      retry_duration     = var.redshift_retry_duration

      dynamic "s3_backup_configuration" {
        for_each = var.enable_s3_backup ? [1] : []
        content {
          bucket_arn          = var.s3_backup_bucket_arn
          role_arn            = local.s3_backup_role_arn
          prefix              = var.s3_backup_prefix
          buffer_size         = var.s3_backup_buffer_size
          buffer_interval     = var.s3_backup_buffer_interval
          compression_format  = var.s3_backup_compression
          error_output_prefix = var.s3_backup_error_output_prefix
          kms_key_arn         = var.s3_backup_enable_encryption ? var.s3_backup_kms_key_arn : null
          cloudwatch_logging_options {
            enabled         = var.s3_backup_enable_log
            log_group_name  = local.s3_backup_cw_log_group_name
            log_stream_name = local.s3_backup_cw_log_stream_name
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = var.enable_destination_log ? [1] : []
        content {
          enabled         = var.enable_destination_log
          log_group_name  = local.destination_cw_log_group_name
          log_stream_name = local.destination_cw_log_stream_name
        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }

    }

  }

  dynamic "elasticsearch_configuration" {
    for_each = local.destination == "elasticsearch" ? [1] : []
    content {
      domain_arn            = var.elasticsearch_domain_arn
      role_arn              = local.firehose_role_arn
      index_name            = var.elasticsearch_index_name
      index_rotation_period = var.elasticsearch_index_rotation_period
      retry_duration        = var.elasticsearch_retry_duration
      type_name             = var.elasticsearch_type_name
      buffering_interval    = var.buffer_interval
      buffering_size        = var.buffer_size
      s3_backup_mode        = local.s3_backup_mode

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = var.enable_destination_log ? [1] : []
        content {
          enabled         = var.enable_destination_log
          log_group_name  = local.destination_cw_log_group_name
          log_stream_name = local.destination_cw_log_stream_name
        }
      }

      #      dynamic "vpc_config" {
      #        for_each = local.elasticsearch_in_vpc ? [1] : []
      #        content {
      #          role_arn           = local.elasticsearch_vpc_role_arn
      #          subnet_ids         = var.elasticsearch_vpc_subnet_ids
      #          security_group_ids = var.elasticsearch_vpc_security_group_ids
      #        }
      #      }

    }
  }

  dynamic "splunk_configuration" {
    for_each = local.destination == "splunk" ? [1] : []
    content {
      hec_endpoint               = var.splunk_hec_endpoint
      hec_token                  = var.splunk_hec_token
      hec_acknowledgment_timeout = var.splunk_hec_acknowledgment_timeout
      hec_endpoint_type          = var.splunk_hec_endpoint_type
      retry_duration             = var.splunk_retry_duration
      s3_backup_mode             = local.s3_backup_mode

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = var.enable_destination_log ? [1] : []
        content {
          enabled         = var.enable_destination_log
          log_group_name  = local.destination_cw_log_group_name
          log_stream_name = local.destination_cw_log_stream_name
        }
      }
    }
  }

  dynamic "http_endpoint_configuration" {
    for_each = local.destination == "http_endpoint" ? [1] : []
    content {
      url                = var.http_endpoint_url
      name               = var.http_endpoint_name
      access_key         = var.http_endpoint_access_key
      buffering_size     = var.buffer_size
      buffering_interval = var.buffer_interval
      role_arn           = local.firehose_role_arn
      s3_backup_mode     = local.s3_backup_mode
      retry_duration     = var.http_endpoint_retry_duration

      dynamic "request_configuration" {
        for_each = var.http_endpoint_enable_request_configuration ? [1] : [0]
        content {
          content_encoding = var.http_endpoint_request_configuration_content_encoding

          dynamic "common_attributes" {
            for_each = var.http_endpoint_request_configuration_common_attributes
            content {
              name  = common_attributes.value.name
              value = common_attributes.value.value
            }
          }

        }
      }

      dynamic "processing_configuration" {
        for_each = local.enable_processing ? [1] : []
        content {
          enabled = local.enable_processing
          dynamic "processors" {
            for_each = local.processors
            content {
              type = processors.value["type"]
              dynamic "parameters" {
                for_each = processors.value["parameters"]
                content {
                  parameter_name  = parameters.value["name"]
                  parameter_value = parameters.value["value"]
                }
              }
            }
          }
        }
      }

      dynamic "cloudwatch_logging_options" {
        for_each = var.enable_destination_log ? [1] : []
        content {
          enabled         = var.enable_destination_log
          log_group_name  = local.destination_cw_log_group_name
          log_stream_name = local.destination_cw_log_stream_name
        }
      }

    }
  }

  tags = var.tags

}

##################
# Cloudwatch
##################
resource "aws_cloudwatch_log_group" "log" {
  count = local.create_destination_logs || local.create_backup_logs ? 1 : 0

  name              = local.cw_log_group_name
  retention_in_days = var.cw_log_retention_in_days

  tags = merge(var.tags, var.cw_tags)
}

resource "aws_cloudwatch_log_stream" "backup" {
  count = local.create_backup_logs ? 1 : 0

  name           = local.cw_log_backup_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}

resource "aws_cloudwatch_log_stream" "destination" {
  count = local.create_destination_logs ? 1 : 0

  name           = local.destination_cw_log_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}