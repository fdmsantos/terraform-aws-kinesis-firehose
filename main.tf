data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "elasticsearch" {
  count = local.elasticsearch_vpc_create_firehose_sg && var.elasticsearch_enable_vpc ? 1 : 0
  id    = var.elasticsearch_vpc_subnet_ids[0]
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  count       = var.create ? 1 : 0
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

      dynamic "vpc_config" {
        for_each = var.elasticsearch_enable_vpc ? [1] : []
        content {
          role_arn           = local.elasticsearch_vpc_role_arn
          subnet_ids         = var.elasticsearch_vpc_subnet_ids
          security_group_ids = local.elasticsearch_vpc_sgs
        }
      }

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
        for_each = var.http_endpoint_enable_request_configuration ? [1] : []
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
  count             = local.create_destination_logs || local.create_backup_logs ? 1 : 0
  name              = local.cw_log_group_name
  retention_in_days = var.cw_log_retention_in_days
  tags              = merge(var.tags, var.cw_tags)
}

resource "aws_cloudwatch_log_stream" "backup" {
  count          = local.create_backup_logs ? 1 : 0
  name           = local.cw_log_backup_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}

resource "aws_cloudwatch_log_stream" "destination" {
  count          = local.create_destination_logs ? 1 : 0
  name           = local.destination_cw_log_stream_name
  log_group_name = aws_cloudwatch_log_group.log[0].name
}

##################
# Security Group
##################
resource "aws_security_group" "firehose" {
  count       = local.elasticsearch_vpc_create_firehose_sg ? 1 : 0
  name        = "${var.name}-sg"
  description = !var.elasticsearch_vpc_security_group_same_as_destination ? "Security group to kinesis firehose" : "Security Group to kinesis firehose and destination"
  vpc_id      = var.elasticsearch_enable_vpc ? data.aws_subnet.elasticsearch[0].vpc_id : var.vpc_security_group_destination_vpc_id

  dynamic "ingress" {
    for_each = var.elasticsearch_vpc_security_group_same_as_destination ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      self        = true
      description = "Allow Inbound HTTPS Traffic"
    }
  }

  tags = merge(var.tags, var.vpc_security_group_tags)
}

resource "aws_security_group_rule" "firehose_es_egress_rule" {
  for_each                 = local.elasticsearch_vpc_create_firehose_sg && !var.elasticsearch_vpc_security_group_same_as_destination ? (local.vpc_create_destination_group ? { for key, value in [aws_security_group.destination[0].id] : key => value } : { for key, value in var.vpc_security_group_destination_ids : key => value }) : {}
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.firehose[0].id
  source_security_group_id = each.value
  description              = "Allow Outbound HTTPS Traffic for destination"
}

resource "aws_security_group" "destination" {
  count       = local.vpc_create_destination_group ? 1 : 0
  name        = "${var.name}-destination-sg"
  description = "Allow Inbound traffic from kinesis firehose stream"
  vpc_id      = local.destination == "elasticsearch" && var.elasticsearch_enable_vpc ? data.aws_subnet.elasticsearch[0].vpc_id : var.vpc_security_group_destination_vpc_id

  dynamic "ingress" {
    for_each = local.destination == "elasticsearch" ? [1] : []
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = local.elasticsearch_vpc_sgs
      description     = "Allow inbound traffic from Kinesis Firehose"
    }
  }

  dynamic "ingress" {
    for_each = local.destination != "elasticsearch" ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.firehose_cidr_blocks[local.destination][data.aws_region.current.name]
      description = "Allow inbound traffic from Kinesis Firehose"
    }
  }

  tags = merge(var.tags, var.vpc_security_group_tags)
}

resource "aws_security_group_rule" "firehose" {
  for_each                 = local.elasticsearch_vpc_configure_existing_firehose_sg ? (var.elasticsearch_vpc_security_group_same_as_destination ? toset(var.vpc_security_group_firehose_ids) : toset(flatten([for security_group in var.vpc_security_group_firehose_ids : [for destination_sg in local.elasticsearch_vpc_destination_sgs : "${security_group}_${destination_sg}"]]))) : toset([])
  type                     = var.elasticsearch_vpc_security_group_same_as_destination ? "ingress" : "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.elasticsearch_vpc_security_group_same_as_destination ? each.value : split("_", each.value)[0]
  source_security_group_id = !var.elasticsearch_vpc_security_group_same_as_destination ? split("_", each.value)[1] : null
  self                     = var.elasticsearch_vpc_security_group_same_as_destination ? true : false
  description              = var.elasticsearch_vpc_security_group_same_as_destination ? "Allow Inbound HTTPS Traffic" : "Allow Outbound HTTPS Traffic"
}

resource "aws_security_group_rule" "destination" {
  for_each                 = local.vpc_configure_destination_group ? (local.destination == "elasticsearch" ? flatten([for security_group in var.vpc_security_group_destination_ids : [for destination_sg in local.elasticsearch_vpc_firehose_sgs : "${security_group}_${destination_sg}"]]) : { for key, value in var.vpc_security_group_destination_ids : key => value }) : {}
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = local.destination != "elasticsearch" ? local.firehose_cidr_blocks[local.destination][data.aws_region.current.name] : null
  security_group_id        = local.destination == "elasticsearch" ? split("_", each.value)[0] : each.value
  source_security_group_id = local.destination == "elasticsearch" ? split("_", each.value)[1] : null
  description              = "Allow Inbound HTTPS Traffic from Firehose"
}
